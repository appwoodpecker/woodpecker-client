//
//  CollectionViewTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/3/9.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "CollectionViewTestViewController.h"
#import "CollectionTestCell.h"

@interface CollectionViewTestViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *list;

@end

@implementation CollectionViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
    [self.collectionView reloadData];
}

- (void)loadData {
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i=0; i<100; i++) {
        [list addObject:[NSNumber numberWithInteger:i]];
    }
    self.list = list;
}

- (void)setupUI {
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CollectionTestCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([CollectionTestCell class])];
    UICollectionViewFlowLayout *layout = self.flowLayout;
    layout.itemSize = CGSizeMake(60, 60);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 8;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionTestCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionTestCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%zd",indexPath.row];
    return cell;
}

@end
