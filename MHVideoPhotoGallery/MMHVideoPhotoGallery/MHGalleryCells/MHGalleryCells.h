//
//  MHGalleryCells.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGalleryViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView*  thumbnail;
@property (nonatomic, strong) UIActivityIndicatorView* act;

@property (nonatomic, copy) void (^saveImage)(BOOL shouldSave);

@end

@interface MHGalleryTableViewCell : UITableViewCell

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *backView;

@end

