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

@interface MHGalleryView ()

@property (strong,nonatomic) UITableView *tableView;
@property(nonatomic,strong) NSArray *galleryDataSource;

@end

@implementation MHGalleryView

#pragma mark - Methods

- (void)updateData:(NSArray *)dataArray
{
    self.galleryDataSource = [NSArray arrayWithArray:dataArray];
    [self.tableView reloadData];
}

- (void)makeOverViewDetailCell:(MHGalleryViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    MHGalleryItem *item = self.galleryDataSource[indexPath.section][indexPath.row];
    
    [cell.thumbnail setContentMode:UIViewContentModeScaleAspectFill];
    
    cell.thumbnail.layer.shadowOffset = CGSizeMake(0, 0);
    cell.thumbnail.layer.shadowRadius = 1.0;
    cell.thumbnail.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.thumbnail.layer.shadowOpacity = 0.5;
    cell.thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.thumbnail.bounds].CGPath;
    cell.thumbnail.layer.cornerRadius = 2.0;
    
    cell.thumbnail.image = nil;
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:item.urlString]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.galleryDataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.galleryDataSource[collectionView.tag] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

static NSString* cellIdentifier = @"TestCell";;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MHGalleryTableViewCell *cell = (MHGalleryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[MHGalleryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.collectionView setDelegate:self];
    [cell.collectionView setDataSource:self];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =nil;
    NSString *cellIdentifier = @"MHGalleryOverViewCell";
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collectionView.tag];
    [self makeOverViewDetailCell:(MHGalleryViewCell*)cell atIndexPath:indexPathNew];
    
    return cell;
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
