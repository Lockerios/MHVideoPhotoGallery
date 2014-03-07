//
//  MHGalleryTableView.h
//  MHVideoPhotoGallery
//
//  Created by Lockerios on 3/7/14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MHGalleryViewDelegate <NSObject>

- (void)galleryViewDidTap:(NSArray*)array imageView:(UIImageView*)imageView forRow:(NSInteger)row inView:(UICollectionView*)view;

@end

@interface MHGalleryView : UIView<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

- (void)updateData:(NSArray*)dataArray;

@property (nonatomic, assign) id<MHGalleryViewDelegate> delegate;

@end
