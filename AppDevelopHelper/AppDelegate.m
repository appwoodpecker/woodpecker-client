//
//  AppDelegate.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "AppDelegate.h"
#import "Preference.h"
#import "PayService.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self otherSetting];
    [self observeAppearanceChange];
    [self setupMain];
}

- (void)setupMain
{
    MainWindowController * mainWC = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    self.mainWC = mainWC;
    [self setInitialWindowFrame];
}

- (void)setInitialWindowFrame {
    NSWindow * window = self.mainWC.window;
    NSPoint screenOrigin = window.screen.frame.origin;
    CGSize screenSize = window.screen.frame.size;
    CGFloat widthFactor = 1/2.0f;
    CGFloat minWidth = 800;
    CGFloat width = MAX(ceilf(screenSize.width*widthFactor), minWidth);
    CGFloat height = ceil(width / (screenSize.width/screenSize.height));
    
    if(![Preference welcomePageShowed]) {
        height += 120.0f;
        width += 60.0f;
    }
    CGFloat left = ceilf(screenSize.width-width)/2.0f + screenOrigin.x;
    CGFloat top = ceilf(screenSize.height-height)/2.0f + 30 + screenOrigin.y;
    
    NSRect windowRect = NSMakeRect(left, top, width, height);
    [window setFrame:windowRect display:NO];
    [self.mainWC showWindow:nil];
}

- (void)otherSetting {
    //关闭智能更换引号
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSAutomaticQuoteSubstitutionEnabled"];
    [Preference addLaunchTimes];
    [Appearance setMGSFragariaColor];
}

- (void)observeAppearanceChange {
    NSApplication *app = [NSApplication sharedApplication];
    [app addObserver:self forKeyPath:@"effectiveAppearance" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"effectiveAppearance"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[Appearance effectiveAppearance] object:self];
        [Appearance setMGSFragariaColor];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

    
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


@end










