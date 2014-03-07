//
//  RecommendTableViewCell.h
//  MHVideoPhotoGallery
//
//  Created by Lockerios on 3/7/14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryCells.h"
#import "UIStrikeThroughLabel.h"

@interface RecommendTableViewCell : MHGalleryTableViewCell

@property (nonatomic, strong) UILabel* recommendString;
@property (nonatomic, strong) UIStrikeThroughLabel* normalPrice;
@property (nonatomic, strong) UILabel* price;

@end
