//
//  MHGalleryImageViewerViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryImageViewerViewController.h"
#import "MHGallery.h"

@interface MHPinchGestureRecognizer : UIPinchGestureRecognizer
@property (nonatomic)NSInteger tag;
@end

@interface MHGalleryImageViewerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UINavigationBarDelegate>

@property (nonatomic, strong) UIToolbar* tb;
@property (nonatomic, strong) UITextView* descriptionView;
@property (nonatomic, strong) UIToolbar* descriptionViewBackground;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, strong) UIPageViewController* pvc;
@property (nonatomic, strong) UIImageView* presentingFromImageView;
@property (nonatomic, strong) UIImageView* dismissFromImageView;
@property (nonatomic, strong) MHTransitionPresentMHGallery* interactivePresentationTranstion;

@property (nonatomic,getter = isUserScrolling) BOOL userScrolls;
@property (nonatomic,getter = isHiddingToolBarAndNavigationBar) BOOL hiddingToolBarAndNavigationBar;

@property (nonatomic, copy) void (^finishedCallback)(UINavigationController* galleryNavMH, NSUInteger photoIndex,MHTransitionDismissMHGallery* interactiveTransition,UIImage* image);

- (void)updateToolBarForItem:(MHGalleryItem*)item;

@end


@interface ImageViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) MHTransitionDismissMHGallery* interactiveTransition;
@property (nonatomic,strong) MHGalleryImageViewerViewController* vc;
@property (nonatomic,strong) MHGalleryItem* item;
@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIActivityIndicatorView* act;
@property (nonatomic,strong) UIImageView* imageView;

@property (nonatomic) NSInteger pageIndex;

-(void)centerImageView;

@property (nonatomic, copy) void (^finishedCallback)(NSUInteger currentIndex,UIImage* image,MHTransitionDismissMHGallery* interactiveTransition);

+ (ImageViewController* )imageViewControllerForMHMediaItem:(MHGalleryItem*)item;

@end