//
//  MHGalleryTableView.h
//  MHVideoPhotoGallery
//
//  Created by Lockerios on 3/7/14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHGalleryView;
@protocol MHGalleryViewDelegate <NSObject>

- (void)galleryViewDidTap:(NSArray*)array imageView:(UIImageView*)imageView forRow:(NSInteger)row inView:(UICollectionView*)view;

- (NSInteger)numberOfSectionsInMHTable;
- (NSInteger)numberOfRowsInSectionInMHTable;
- (CGFloat)heightForRowAtIndexPathInMHTable:(NSIndexPath*)indexPath;
- (UITableViewCell*)cellForRowAtIndexPathInMHTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath reuseCellIdentifier:(NSString*)identifier inMH:(MHGalleryView*)galleryView;

- (NSInteger)numberOfSectionsInCollectionView;
- (NSInteger)numberOfCellInCollectionViewWithTag:(NSInteger)collectionTag;

@end


@interface MHGalleryView : UIView<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

- (void)updateData:(NSArray*)dataArray;

@property (nonatomic, assign) id<MHGalleryViewDelegate> delegate;
@end
