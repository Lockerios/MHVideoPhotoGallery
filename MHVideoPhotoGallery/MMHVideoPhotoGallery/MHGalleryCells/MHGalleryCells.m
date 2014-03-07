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

    }
    
    return self;
}

@end