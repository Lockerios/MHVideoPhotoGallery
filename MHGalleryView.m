//
//  MHGalleryTableView.m
//  MHVideoPhotoGallery
//
//  Created by Lockerios on 3/7/14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryView.h"
#import "MHGallery.h"
#import "MHGalleryCells.h"

static NSString* cellIdentifier = @"MHTableViewCellIdentifier";
static NSString *MHGalleryOverViewCell = @"MHGalleryOverViewCell";

@interface MHGalleryView ()

@property (strong,nonatomic) UITableView *tableView;
@property(nonatomic,strong) NSArray *galleryDataSource;

@end

@implementation MHGalleryView

#pragma mark - Methods

- (void)updateData
{
    [self.tableView reloadData];
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        [self addSubview:_tableView];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    return self;
}

#pragma mark - Actions

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfSectionsInMHTable)]) {
        return [_delegate numberOfSectionsInMHTable];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(heightForRowAtIndexPathInMHTable:)]) {
        return [_delegate heightForRowAtIndexPathInMHTable:indexPath];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfRowsInSectionInMHTable)]) {
        return [_delegate numberOfRowsInSectionInMHTable];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellForRowAtIndexPathInMHTable:atIndexPath:reuseCellIdentifier:reuseCollectionIdentifier:inMH:)]) {
        return [_delegate cellForRowAtIndexPathInMHTable:tableView atIndexPath:indexPath reuseCellIdentifier:cellIdentifier reuseCollectionIdentifier:MHGalleryOverViewCell inMH:self];
    } else {
        return nil;
    }
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfCellInCollectionViewWithTag:)]) {
        return [_delegate numberOfCellInCollectionViewWithTag:collectionView.tag];
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfSectionsInCollectionView)]) {
        return [_delegate numberOfSectionsInCollectionView];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellForItemAtIndexPathInMHCollection:atIndexPath:reuseCellIdentifier:)]) {
        return [_delegate cellForItemAtIndexPathInMHCollection:collectionView atIndexPath:indexPath reuseCellIdentifier:MHGalleryOverViewCell];
    } else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = [(MHGalleryViewCell*)[collectionView cellForItemAtIndexPath:indexPath] thumbnail];
    NSArray *galleryData = self.galleryDataSource[collectionView.tag];
    
    if (_delegate && [_delegate respondsToSelector:@selector(galleryViewDidTap:imageView:forRow:inView:)]) {
        [_delegate galleryViewDidTap:galleryData imageView:imageView forRow:indexPath.row inView:collectionView];
    }
}

@end
