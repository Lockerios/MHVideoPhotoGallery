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

@required
- (NSInteger)numberOfSectionsInMHTable;
- (NSInteger)numberOfRowsInSectionInMHTable;
- (CGFloat)heightForRowAtIndexPathInMHTable:(NSIndexPath*)indexPath;
- (UITableViewCell*)cellForRowAtIndexPathInMHTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath reuseCellIdentifier:(NSString*)identifier reuseCollectionIdentifier:(NSString*)cIdentifier inMH:(MHGalleryView*)galleryView;

- (NSInteger)numberOfSectionsInCollectionView;
- (NSInteger)numberOfCellInCollectionViewWithTag:(NSInteger)collectionTag;
- (UICollectionViewCell*)cellForItemAtIndexPathInMHCollection:(UICollectionView*)collection atIndexPath:(NSIndexPath*)indexPath reuseCellIdentifier:(NSString*)identifier;

@optional
- (void)galleryViewDidTap:(NSArray*)array imageView:(UIImageView*)imageView forRow:(NSInteger)row inView:(UICollectionView*)view;

@end


@interface MHGalleryView : UIView<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

- (void)updateData;

@property (nonatomic, assign) id<MHGalleryViewDelegate> delegate;
@end
