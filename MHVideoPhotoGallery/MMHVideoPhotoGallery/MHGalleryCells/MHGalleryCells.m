//
//  MHGalleryCells.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHGalleryCells.h"

@implementation MHGalleryViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _thumbnail = [[UIImageView alloc] initWithFrame:self.bounds];
        self.thumbnail.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.clipsToBounds = YES;
        [[self contentView] addSubview:self.thumbnail];
        
        _act = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        self.act.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.act.color = [UIColor whiteColor];
        self.act.tag = 405;
        [[self contentView] addSubview:self.act];
    }
    return self;
}

- (void)saveImage:(id)sender {
    self.saveImage(YES);
}

@end


@implementation MHGalleryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        
//        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 330)];
//        
//        self.backView.layer.masksToBounds = NO;
//        self.backView.layer.shadowOffset = CGSizeMake(0, 0);
//        self.backView.layer.shadowRadius = 1.0;
//        self.backView.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.backView.layer.shadowOpacity = 0.5;
//        self.backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.backView.bounds].CGPath;
//        self.backView.layer.cornerRadius = 2.0;
//        
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
//        layout.itemSize = CGSizeMake(270, 225);
//        layout.minimumLineSpacing = 15;
//        layout.minimumInteritemSpacing = 15;
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        
//        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
//        self.collectionView.backgroundColor = [UIColor clearColor];
//        
//        [self.collectionView registerClass:[MHGalleryViewCell class] forCellWithReuseIdentifier:@"MHGalleryOverViewCell"];
//        
//        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//        
//        [self.collectionView setShowsHorizontalScrollIndicator:NO];
//        
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        [self.contentView addSubview:self.backView];
//        [self.contentView addSubview:self.collectionView];
    }
    
    return self;
}

@end