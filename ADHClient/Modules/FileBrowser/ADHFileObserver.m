//
//  ADHFileObserver.m
//  ADHClient
//
//  Created by 张小刚 on 2018/7/5.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "ADHFileObserver.h"
#import "ADHFileItem.h"
#import "ADHFileBrowserUtil.h"
#import "ADHFileActivityItem.h"

@interface ADHFileObserverItem : NSObject

@property (nonatomic, assign) int fd;
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL isDir;

@end

@implementation ADHFileObserverItem

@end

@interface ADHFileEvent : NSObject

@property (nonatomic, strong) ADHFileObserverItem * observeItem;
@property (nonatomic, assign) dispatch_source_vnode_flags_t event;
@property (nonatomic, strong) NSDate *date;

@end

@implementation ADHFileEvent

@end

#pragma mark -----------------   ADHFileObserver   ----------------

@interface ADHFileObserver ()

@property (nonatomic, strong) NSString *workPath;
@property (nonatomic, strong) NSMutableArray<ADHFileObserverItem *> *observeList;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_queue_t handlerQueue;
@property (nonatomic, strong) ADHFileItem *rootFileItem;
@property (nonatomic, strong) NSMutableArray<ADHFileEvent *> *eventList;

@property (nonatomic, strong) dispatch_source_t eventTimer;

@end

@implementation ADHFileObserver

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {
    self.queue = dispatch_queue_create("studio.lifebetter.service.fileobserver", DISPATCH_QUEUE_SERIAL);
    self.handlerQueue = dispatch_queue_create("studio.lifebetter.service.fileobserver.handler", DISPATCH_QUEUE_SERIAL);
    self.observeList = [NSMutableArray array];
    self.eventList = [NSMutableArray array];
}

- (NSString *)relativePath {
    NSString *relativePath = nil;
    if(self.workDir.length > 0) {
        relativePath = self.workDir;
    }else if(self.containerName.length > 0) {
        relativePath = [ADHFileUtil getGroupContainerPath:self.containerName];
    }else {
        relativePath = [ADHFileUtil appPath];
    }
    return relativePath;
}

- (void)startWithPath: (NSString *)workPath {
    [self reset];
    self.workPath = workPath;
    [self performInHandlerQueue:^{
        [self scanWorkPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL isExists = NO;
        NSString *relativePath = [self relativePath];
        NSString *path = [relativePath stringByAppendingPathComponent:workPath];
        isExists = [fm fileExistsAtPath:path isDirectory:&isDir];
        if(isExists) {
            [self addObserverItem:workPath isDir:isDir];
        }
        if(isDir) {
            NSDirectoryEnumerator *directoryEnumerator = [fm enumeratorAtPath:path];
            for (NSString *relativePath in directoryEnumerator) {
                NSString *itemPath = [path stringByAppendingPathComponent:relativePath];
                BOOL isDir = NO;
                [fm fileExistsAtPath:itemPath isDirectory:&isDir];
                [self addObserverItem:[workPath stringByAppendingPathComponent:relativePath] isDir:isDir];
            }
        }
    }];
}


- (void)stop {
    [self reset];
}

- (void)reset {
    if(self.observeList.count > 0) {
        for (ADHFileObserverItem *item in self.observeList) {
            dispatch_source_t source = item.source;
            int fd = item.fd;
            dispatch_source_cancel(source);
            close((int)fd);
        }
    }
    [self.observeList removeAllObjects];
    [self.eventList removeAllObjects];
    self.rootFileItem = nil;
}

- (void)scanWorkPath {
    ADHFileItem *rootItem = [ADHFileBrowserUtil scanFolder:self.workPath relativePath:[self relativePath]];
    self.rootFileItem = rootItem;
}

/**
 * observe folder or file update
 * folder, it only observe its first-level children, and itself
 * file, it only observe itself
 */
- (void)addObserverItem: (NSString *)itemPath isDir: (BOOL)isDir {
    NSString *path = [[self relativePath] stringByAppendingPathComponent:itemPath];
    int fd = open([path fileSystemRepresentation], O_EVTONLY);
    if(fd <= 0) {
        return;
    }
//    NSLog(@"observer -> %@",itemPath);
    dispatch_source_vnode_flags_t mask = 0;
    if(isDir) {
        //write: add/remove file
        //delete: delete
        //extend: ?
        //rename: rename
        //attribute: metadata
        mask = DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE;
    }else {
        //write: edit
        //delte: delete
        //extend: size changed
        //rename: rename
        //attribute: metadata
        mask = DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE;
    }
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, mask, self.queue);
    ADHFileObserverItem *item = [[ADHFileObserverItem alloc] init];
    item.source = source;
    item.path = itemPath;
    item.isDir = isDir;
    item.fd = fd;
    dispatch_set_context(source, (__bridge void * _Nullable)(item));
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(source, ^{
        ADHFileObserverItem *item = (__bridge ADHFileObserverItem *)(dispatch_get_context(source));
        dispatch_source_vnode_flags_t mask = dispatch_source_get_data(source);
        [wself handleItemEvent:mask forItem:item];
    });
    dispatch_resume(source);
    [self.observeList addObject:item];
//    NSLog(@"---> add observe %@ %@",itemPath, isDir?@"folder":@"");
}

/**
 * cancel observe file item cause it was deleted
 */
- (void)removeObserverItem: (NSString *)itemPath isDir: (BOOL)isDir {
    ADHFileObserverItem * targetItem = nil;
    for (ADHFileObserverItem *item in self.observeList) {
        if([item.path isEqualToString:itemPath] && item.isDir == isDir) {
            targetItem = item;
        }
    }
    if(targetItem) {
        dispatch_source_t source = targetItem.source;
        int fd = targetItem.fd;
        dispatch_source_cancel(source);
        close((int)fd);
        [self.observeList removeObject:targetItem];
//        NSLog(@"---> remove observe %@ %@",itemPath, isDir?@"folder":@"");
    }
}


- (void)handleItemEvent: (dispatch_source_vnode_flags_t)event forItem: (ADHFileObserverItem *)item {
    ADHFileEvent *targetEvent = nil;
    for (ADHFileEvent *fEvent in self.eventList) {
        if([fEvent.observeItem.path isEqualToString:item.path] && event == fEvent.event) {
            targetEvent = fEvent;
        }
    }
    if(!targetEvent) {
        ADHFileEvent *fileEvent = [[ADHFileEvent alloc] init];
        fileEvent.event = event;
        fileEvent.observeItem = item;
        fileEvent.date = [NSDate date];
        [self.eventList addObject:fileEvent];
    }else {
        targetEvent.date = [NSDate date];
    }
    [self prepareHandleEvent];
}

#pragma mark -----------------   handle event   ----------------

- (void)clearEventTimer {
    if(self.eventTimer) {
        dispatch_source_cancel(self.eventTimer);
        self.eventTimer = nil;
    }
}

- (void)prepareHandleEvent {
    [self clearEventTimer];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.handlerQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self handlingEvent];
    });
    dispatch_resume(timer);
    self.eventTimer = timer;
}

- (void)performInHandlerQueue: (dispatch_block_t)block {
    dispatch_async(self.handlerQueue, block);
}

- (void)handlingEvent {
//    NSLog(@"event count [before] -> %zd",self.eventList.count);
    [self clearEventTimer];
    //handle event now
    NSArray *events = [NSArray arrayWithArray:self.eventList];
    for (ADHFileEvent *event in events) {
        [self handleFileEvent:event];
    }
    dispatch_async(self.queue, ^{
        [self.eventList removeObjectsInArray:events];
//        NSLog(@"event count [after] -> %zd",self.eventList.count);
    });
}

- (void)handleFileEvent: (ADHFileEvent *)fileEvent {
    ADHFileObserverItem *item = fileEvent.observeItem;
    dispatch_source_vnode_flags_t event = fileEvent.event;
    NSString *itemPath = item.path;
    NSMutableArray *activityList = [NSMutableArray array];
    if(event & DISPATCH_VNODE_DELETE) {
        //delete file in folder
        ADHFileActivityItem *activity = [[ADHFileActivityItem alloc] init];
        activity.path = itemPath;
        activity.type = ADHFileActivityRemove;
        activity.isDir = item.isDir;
        activity.date = fileEvent.date;
        [activityList addObject:activity];
        [self removeObserverItem:itemPath isDir:item.isDir];
        //remove this file record from local-file-item
        ADHFileItem *thisItem = [ADHFileBrowserUtil searchFileItemWithPath:itemPath inFileItem:self.rootFileItem isDir:item.isDir];
        if(thisItem) {
            ADHFileItem *parent = thisItem.parent;
            NSArray *subItems = parent.subItems;
            NSMutableArray *mutableSubItems = [subItems mutableCopy];
            [mutableSubItems removeObject:thisItem];
            parent.subItems = mutableSubItems;
        }else {
//            NSAssert(false, @"something wrong...");
        }
    }else {
        //new file in folder or file edited
        NSString *itemPath = item.path;
        NSString *relativePath = [self relativePath];
        if(item.isDir) {
            /*
                add/remove file or folder in this folder, we find out which item is new added,
                we only handle the add event because remove event already was handled in DISPATCH_VNODE_DELETE event.
             */
            ADHFileItem * parentItem = [ADHFileBrowserUtil searchFileItemWithPath:itemPath inFileItem:self.rootFileItem isDir:YES];
            NSArray * subItems = parentItem.subItems;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *error = nil;
            NSString *folderPath = [relativePath stringByAppendingPathComponent:itemPath];
            NSArray *fileKeys = @[
                                  NSURLIsRegularFileKey,
                                  ];
            NSURL *folderURL = [NSURL URLWithString:folderPath];
            if(!folderURL) return;
            NSArray<NSURL *> *itemURLs = [fm contentsOfDirectoryAtURL:folderURL includingPropertiesForKeys:fileKeys options:0 error:&error];
            if(itemURLs.count == 0) return;
            //new added file or dir
            
            NSString *newFileName = nil;
            BOOL newFileDir = NO;
            for (NSURL *itemURL in itemURLs) {
                NSString *itemName = [itemURL lastPathComponent];
                NSNumber *isRegularFile = nil;
                [itemURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:nil];
                BOOL isDir = ![isRegularFile boolValue];
                BOOL pass = NO;
                for (ADHFileItem *subItem in subItems) {
                    if([subItem.name isEqualToString:itemName] && subItem.isDir == isDir) {
                        pass = YES;
                        break;
                    }
                }
                if(!pass) {
                    newFileName = itemName;
                    newFileDir = isDir;
                    break;
                }
            }
            //then if add, we observe it
            if(newFileName) {
                NSString *filePath = [itemPath stringByAppendingPathComponent:newFileName];
                ADHFileActivityItem *activity = [[ADHFileActivityItem alloc] init];
                activity.path = filePath;
                activity.type = ADHFileActivityAdd;
                activity.isDir = newFileDir;
                activity.date = fileEvent.date;
                [activityList addObject:activity];
                [self addObserverItem:filePath isDir:newFileDir];
                
                ADHFileItem *thisItem = nil;
                if(newFileDir) {
                    thisItem = [ADHFileBrowserUtil scanFolder:filePath relativePath:relativePath];
                }else {
                    thisItem = [ADHFileBrowserUtil scanFileAtPath:filePath relativePath:relativePath];
                }
                if(thisItem) {
                    thisItem.parent = parentItem;
                    NSArray *subItems = parentItem.subItems;
                    NSMutableArray *mutableSubItems = [subItems mutableCopy];
                    [mutableSubItems addObject:thisItem];
                    parentItem.subItems = mutableSubItems;
                }else {
//                    NSAssert(false, @"something wrong...");
                }
            }
        }else {
            //edit this file
            ADHFileActivityItem *activity = [[ADHFileActivityItem alloc] init];
            activity.path = itemPath;
            activity.type = ADHFileActivityEdit;
            activity.isDir = NO;
            activity.date = fileEvent.date;
            [activityList addObject:activity];
            //暂时不需要更新文件的md5和时间等，暂时用不到
        }
    }
    if(activityList.count > 0) {
        //finally, we post update
        [self postActivityEvent:activityList[0]];
    }
}

- (void)postActivityEvent: (ADHFileActivityItem *)activity {
    NSDictionary *data = [activity dicPresentation];
    [[ADHApiClient sharedApi] requestWithService:@"adh.filebrowser"
                                          action:@"fileUpdate"
                                            body: data
                                       onSuccess:^(NSDictionary *body, NSData *payload) {
                                           
                                       } onFailed:^(NSError *error) {
                                           
                                       }];
}


#pragma mark -----------------   util   ----------------

- (NSString *)readbleTextWithEvent: (dispatch_source_vnode_flags_t)event {
    NSMutableArray *components = [NSMutableArray array];
    if(event & DISPATCH_VNODE_DELETE) {
        [components addObject:@"DELETE"];
    }
    if(event & DISPATCH_VNODE_WRITE) {
        [components addObject:@"WRITE"];
    }
    if(event & DISPATCH_VNODE_EXTEND) {
        [components addObject:@"EXTEND"];
    }
    if(event & DISPATCH_VNODE_ATTRIB) {
        [components addObject:@"ATTRIB"];
    }
    if(event & DISPATCH_VNODE_LINK) {
        [components addObject:@"LINK"];
    }
    if(event & DISPATCH_VNODE_RENAME) {
        [components addObject:@"RENAME"];
    }
    if(event & DISPATCH_VNODE_REVOKE) {
        [components addObject:@"REVOKE"];
    }
    if(event & DISPATCH_VNODE_FUNLOCK) {
        [components addObject:@"FUNLOCK"];
    }
    NSString *text = [components componentsJoinedByString:@", "];
    return text;
}

@end
