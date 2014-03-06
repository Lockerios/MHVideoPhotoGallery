//
//  MHGalleryImageViewerViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "MHGalleryImageViewerViewController.h"

#pragma mark - MHPinchGestureRecognizer

@implementation MHPinchGestureRecognizer
@end

#pragma mark - MHGalleryImageViewerViewController

@interface MHGalleryImageViewerViewController()

@property (nonatomic, strong) NSArray *galleryItems;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIBarButtonItem *leftBarButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end


@implementation MHGalleryImageViewerViewController

#pragma mark - Methods

-(void)donePressed{
    ImageViewController *imageViewer = self.pvc.viewControllers.firstObject;
    
    MHTransitionDismissMHGallery *dismissTransiton = [MHTransitionDismissMHGallery new];
    dismissTransiton.orientationTransformBeforeDismiss = [(NSNumber *)[self.navigationController.view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    self.finishedCallback(self.navigationController,self.pageIndex,dismissTransiton,imageViewer.imageView.image);
}

-(void)leftPressed:(id)sender{
    self.rightBarButton.enabled = YES;
    
    ImageViewController *theCurrentViewController = [self.pvc.viewControllers firstObject];
    NSUInteger indexPage = theCurrentViewController.pageIndex;
    ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage-1]];
    imageViewController.pageIndex = indexPage-1;
    imageViewController.vc = self;
    
    if (indexPage-1 == 0) {
        self.leftBarButton.enabled = NO;
    }
    __block MHGalleryImageViewerViewController*blockSelf = self;
    
    [self.pvc setViewControllers:@[imageViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        blockSelf.pageIndex = imageViewController.pageIndex;
    }];
}

-(void)rightPressed:(id)sender{
    [self.leftBarButton setEnabled:YES];
    ImageViewController *theCurrentViewController = [self.pvc.viewControllers firstObject];
    NSUInteger indexPage = theCurrentViewController.pageIndex;
    ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage+1]];
    imageViewController.pageIndex = indexPage+1;
    imageViewController.vc = self;
    
    if (indexPage+1 == self.galleryItems.count-1) {
        self.rightBarButton.enabled = NO;
    }
    __block MHGalleryImageViewerViewController*blockSelf = self;
    
    [self.pvc setViewControllers:@[imageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        blockSelf.pageIndex = imageViewController.pageIndex;
    }];
}

-(void)updateDescriptionLabelForIndex:(NSInteger)index{
    if (index < self.galleryItems.count) {
        MHGalleryItem *item = self.galleryItems[index];
        self.descriptionView.text = item.description;
        
        if (item.attributedString) {
            self.descriptionView.attributedText = item.attributedString;
        }
        CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
        
        self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
        if (self.descriptionView.text.length >0) {
            [self.descriptionViewBackground setHidden:NO];
            self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
        }else{
            [self.descriptionViewBackground setHidden:YES];
        }
    }
}

-(void)updateTitleForIndex:(NSInteger)pageIndex{
    NSString *localizedString  = MHGalleryLocalizedString(@"imagedetail.title.current");
    self.navigationItem.title = [NSString stringWithFormat:localizedString,@(pageIndex+1),@(self.galleryItems.count)];
}

-(void)updateToolBarForItem:(MHGalleryItem*)item{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self.tb setItems:@[flex,self.leftBarButton,flex,self.rightBarButton,flex]];
}

#pragma mark - Viewlifecycle

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.galleryItems = [MHGalleryDataManager sharedDataManager].galleryItems;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(donePressed)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.pvc =[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                            options:@{ UIPageViewControllerOptionInterPageSpacingKey : @30.f }];
    self.pvc.delegate = self;
    self.pvc.dataSource = self;
    
    if (MHiOS7) {
        self.pvc.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    MHGalleryItem *item = self.galleryItems[self.pageIndex];
    
    ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:item];
    imageViewController.pageIndex = self.pageIndex;
    imageViewController.vc = self;
    
    [self.pvc setViewControllers:@[imageViewController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    
    
    [self addChildViewController:self.pvc];
    [self.pvc didMoveToParentViewController:self];
    [self.view addSubview:[self.pvc view]];
    
    self.tb = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        if (self.view.bounds.size.height > self.view.bounds.size.width) {
            self.tb.frame = CGRectMake(0, self.view.frame.size.width-44, self.view.frame.size.height, 44);
        }
    }
    
    self.tb.tag = 307;
    self.tb.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    self.leftBarButton = [[UIBarButtonItem alloc]initWithImage:MHGalleryImage(@"left_arrow")
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(leftPressed:)];
    
    self.rightBarButton = [[UIBarButtonItem alloc]initWithImage:MHGalleryImage(@"right_arrow")
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(rightPressed:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                         target:self
                                                                         action:nil];
    
    [self.tb setItems:@[flex,self.leftBarButton,flex,self.rightBarButton,flex]];
    
    if (self.pageIndex == 0) {
        self.leftBarButton.enabled =NO;
    }
    if(self.pageIndex == self.galleryItems.count-1){
        self.rightBarButton.enabled =NO;
    }
    
    self.descriptionViewBackground = [[UIToolbar alloc]initWithFrame:CGRectZero];
    self.descriptionView = [[UITextView alloc]initWithFrame:CGRectZero];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    self.descriptionView.font = [UIFont systemFontOfSize:15];
    self.descriptionView.text = item.description;
    self.descriptionView.textColor = [UIColor blackColor];
    self.descriptionView.scrollEnabled = NO;
    self.descriptionView.userInteractionEnabled = NO;
    
    
    if([MHGalleryDataManager sharedDataManager].barColor){
        self.tb.barTintColor = [MHGalleryDataManager sharedDataManager].barColor;
        self.navigationController.navigationBar.barTintColor =[MHGalleryDataManager sharedDataManager].barColor;
        self.descriptionViewBackground.barTintColor = [MHGalleryDataManager sharedDataManager].barColor;
    }
    
    CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
    
    self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
    if (self.descriptionView.text.length >0) {
        self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
    }else{
        [self.descriptionViewBackground setHidden:YES];
    }
    [(UIScrollView*)self.pvc.view.subviews[0] setDelegate:self];
    [(UIGestureRecognizer*)[[self.pvc.view.subviews[0] gestureRecognizers] firstObject] setDelegate:self];
    
    [self updateTitleForIndex:self.pageIndex];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (![self.descriptionViewBackground isDescendantOfView:self.view]) {
        [self.view addSubview:self.descriptionViewBackground];
    }
    if (![self.descriptionView isDescendantOfView:self.view]) {
        [self.view addSubview:self.descriptionView];
    }
    if (![self.tb isDescendantOfView:self.view]) {
        [self.view addSubview:self.tb];
    }
    [[self.pvc.view.subviews firstObject] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return  UIStatusBarStyleDefault;
}

#pragma mark - Actions

#pragma mark UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        if (touch.view.tag != 508) {
            return YES;
        }
    }
    return ([touch.view isKindOfClass:[UIControl class]] == NO);
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.userScrolls = NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.userScrolls = YES;
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger pageIndex =self.pageIndex;
    
    [self updateDescriptionLabelForIndex:pageIndex];
    
    if (scrollView.contentOffset.x > (self.view.frame.size.width+self.view.frame.size.width/2)) {
        pageIndex++;
        [self updateDescriptionLabelForIndex:pageIndex];
    }
    if (scrollView.contentOffset.x < self.view.frame.size.width/2) {
        pageIndex--;
        [self updateDescriptionLabelForIndex:pageIndex];
    }
    [self updateTitleForIndex:pageIndex];
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(ImageViewController *)vc{
    self.leftBarButton.enabled =YES;
    self.rightBarButton.enabled =YES;
    
    NSInteger indexPage = vc.pageIndex;
    
    if (indexPage ==0) {
        self.leftBarButton.enabled = NO;
        ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:nil];
        imageViewController.pageIndex = 0;
        imageViewController.vc = self;
        
        return imageViewController;
    }
    ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage-1]];
    imageViewController.pageIndex = indexPage-1;
    imageViewController.vc = self;
    
    return imageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(ImageViewController *)vc{
    self.leftBarButton.enabled = YES;
    self.rightBarButton.enabled = YES;
    
    
    NSInteger indexPage = vc.pageIndex;
    
    if (indexPage ==self.galleryItems.count-1) {
        self.rightBarButton.enabled = NO;
        ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:nil];
        imageViewController.pageIndex = self.galleryItems.count-1;
        imageViewController.vc = self;
        return imageViewController;
    }
    ImageViewController *imageViewController =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage+1]];
    imageViewController.pageIndex  = indexPage+1;
    imageViewController.vc = self;
    return imageViewController;
}

#pragma mark UIPageViewControllerDelegate

-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray *)previousViewControllers
      transitionCompleted:(BOOL)completed{
    
    self.pageIndex = [[pageViewController.viewControllers firstObject] pageIndex];
    
    if (completed) {
        [self updateToolBarForItem:self.galleryItems[self.pageIndex]];
    }
}

#pragma mark UINavigationControllerDelegate

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
        return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    return nil;
}

#pragma mark UIViewControllerRotation

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    self.tb.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    self.pvc.view.bounds = self.view.bounds;
    [[self.pvc.view.subviews firstObject] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
    
}

@end

#pragma mark - ImageViewController

@interface ImageViewController ()

@property (nonatomic, strong) NSNumberFormatter        *numberFormatter;
@property (nonatomic,strong ) UIPanGestureRecognizer   *pan;
@property (nonatomic,strong ) MHPinchGestureRecognizer *pinch;

@property (nonatomic)         CGPoint                  pointToCenterAfterResize;
@property (nonatomic)         CGFloat                  scaleToRestoreAfterResize;
@property (nonatomic)         CGPoint                  startPoint;
@property (nonatomic)         CGPoint                  lastPoint;
@property (nonatomic)         CGPoint                  lastPointPop;

@end


@implementation ImageViewController

#pragma mark - Methods

+ (ImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item
{
    if (item) {
        return [[self alloc]initWithMHMediaItem:item];
    }
    return nil;
}

-(void)centerImageView
{
    if (self.imageView.image) {
        CGRect frame  = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
        
        if (self.scrollView.contentSize.width==0 && self.scrollView.contentSize.height==0) {
            frame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,self.scrollView.bounds);
        }
        
        CGSize boundsSize = self.scrollView.bounds.size;
        
        CGRect frameToCenter = CGRectMake(0,0 , frame.size.width, frame.size.height);
        
        if (frameToCenter.size.width < boundsSize.width){
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }else{
            frameToCenter.origin.x = 0;
        }
        if (frameToCenter.size.height < boundsSize.height){
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }else{
            frameToCenter.origin.y = 0;
        }
        self.imageView.frame = frameToCenter;
    }
}

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    self.pointToCenterAfterResize = [self.scrollView convertPoint:boundsCenter toView:self.imageView];
    self.scaleToRestoreAfterResize = self.scrollView.zoomScale;
}

- (void)recoverFromResizing
{
    self.scrollView.zoomScale = MIN(self.scrollView.maximumZoomScale, MAX(self.scrollView.minimumZoomScale, _scaleToRestoreAfterResize));
    CGPoint boundsCenter = [self.scrollView convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.scrollView.bounds.size.width / 2.0,
                                 boundsCenter.y - self.scrollView.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.scrollView.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (CGFloat)checkProgressValue:(CGFloat)progress
{
    CGFloat progressChecked =progress;
    if (progressChecked <0) {
        progressChecked = -progressChecked;
    }
    if (progressChecked >=1) {
        progressChecked =0.99;
    }
    return progressChecked;
}

- (void)userDidPinch:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale <1) {
            self.imageView.frame = self.scrollView.frame;
            
            self.lastPointPop = [recognizer locationInView:self.view];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            recognizer.cancelsTouchesInView = YES;
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (recognizer.numberOfTouches <2) {
            recognizer.enabled =NO;
            recognizer.enabled =YES;
        }
        
        CGPoint point = [recognizer locationInView:self.view];
        self.lastPointPop = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (void)userDidPan:(UIPanGestureRecognizer*)recognizer
{
    BOOL userScrolls = self.vc.userScrolls;
    
    if (![MHGalleryDataManager sharedDataManager].disableToDismissGalleryWithScrollGestureOnStartOrEndPoint) {
        if (!self.interactiveTransition) {
            if (self.pageIndex ==0) {
                if ([(UIPanGestureRecognizer*)recognizer translationInView:self.view].x >=0) {
                    userScrolls =NO;
                    self.vc.userScrolls = NO;
                }else{
                    recognizer.cancelsTouchesInView = YES;
                    recognizer.enabled =NO;
                    recognizer.enabled =YES;
                }
            }
            if ((self.pageIndex == [MHGalleryDataManager sharedDataManager].galleryItems.count-1)) {
                if ([(UIPanGestureRecognizer*)recognizer translationInView:self.view].x <=0) {
                    userScrolls =NO;
                }else{
                    recognizer.cancelsTouchesInView = YES;
                    recognizer.enabled =NO;
                    recognizer.enabled =YES;
                }
            }
        }else{
            userScrolls = NO;
        }
    }
    
    if (!userScrolls || recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progressY = (self.startPoint.y - [(UIPanGestureRecognizer*)recognizer translationInView:self.view].y)/(self.view.frame.size.height/2);
        progressY = [self checkProgressValue:progressY];
        CGFloat progressX = (self.startPoint.x - [(UIPanGestureRecognizer*)recognizer translationInView:self.view].x)/(self.view.frame.size.width/2);
        progressX = [self checkProgressValue:progressX];
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.startPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
        }else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (!self.interactiveTransition ) {
                self.startPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
                self.lastPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
                self.interactiveTransition = [MHTransitionDismissMHGallery new];
                self.interactiveTransition.orientationTransformBeforeDismiss = [(NSNumber *)[self.navigationController.view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
                self.interactiveTransition.interactive = YES;
                
                if (self.navigationController.viewControllers.count ==2) {
                    
                }else{
                    self.vc.finishedCallback(self.navigationController,self.pageIndex,self.interactiveTransition,self.imageView.image);
                }
            }else{
                CGPoint currentPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
                
                if ([MHGalleryDataManager sharedDataManager].shouldFixXValueForDismissMHGallery) {
                    self.interactiveTransition.changedPoint = CGPointMake(self.startPoint.x, self.lastPoint.y-currentPoint.y);
                }else{
                    self.interactiveTransition.changedPoint = CGPointMake(self.lastPoint.x-currentPoint.x, self.lastPoint.y-currentPoint.y);
                }
                progressY = [self checkProgressValue:progressY];
                progressX = [self checkProgressValue:progressX];
                
                if (![MHGalleryDataManager sharedDataManager].shouldFixXValueForDismissMHGallery) {
                    if (progressX> progressY) {
                        progressY = progressX;
                    }
                }
                
                [self.interactiveTransition updateInteractiveTransition:progressY];
                self.lastPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
            }
            
        }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (self.interactiveTransition) {
                CGFloat velocityY = [recognizer velocityInView:self.view].y;
                if (velocityY <0) {
                    velocityY = -velocityY;
                }
                if (![MHGalleryDataManager sharedDataManager].shouldFixXValueForDismissMHGallery) {
                    if (progressX> progressY) {
                        progressY = progressX;
                    }
                }
                
                if (progressY > 0.35 || velocityY >700) {
                    [[self statusBarObject] setAlpha:1];
                    [self.interactiveTransition finishInteractiveTransition];
                }else {
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self.interactiveTransition cancelInteractiveTransition];
                }
                self.interactiveTransition = nil;
            }
        }
    }
}

- (void)changeToErrorImage
{
    self.imageView.image = MHGalleryImage(@"error");
}

-(UIView*)statusBarObject{
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    return statusBar;
}

-(void)handelImageTap:(UIGestureRecognizer *)gestureRecognizer{
    if (!self.vc.isHiddingToolBarAndNavigationBar) {
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationBar.alpha =0;
            self.vc.tb.alpha =0 ;
            self.scrollView.backgroundColor = [UIColor blackColor];
            self.vc.pvc.view.backgroundColor = [UIColor blackColor];
            
            self.vc.descriptionView.alpha =0;
            self.vc.descriptionViewBackground.alpha =0;
            [self statusBarObject].alpha =0 ;
        } completion:^(BOOL finished) {
            
            self.vc.hiddingToolBarAndNavigationBar = YES;
            self.navigationController.navigationBar.hidden  =YES;
            self.vc.tb.hidden =YES;
        }];
    }else{
        self.navigationController.navigationBar.hidden = NO;
        self.vc.tb.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            
            self.navigationController.navigationBar.alpha =1;
            self.vc.tb.alpha = 1;
            self.scrollView.backgroundColor = [UIColor whiteColor];
            self.vc.pvc.view.backgroundColor = [UIColor whiteColor];
            [self statusBarObject].alpha =1;
            self.vc.descriptionView.alpha =1;
            self.vc.descriptionViewBackground.alpha =1;
        } completion:^(BOOL finished) {
            self.vc.hiddingToolBarAndNavigationBar = NO;
        }];
        
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.imageView.image isEqual:MHGalleryImage(@"error")]) {
        return;
    }
    if (self.scrollView.zoomScale >1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    [self centerImageView];
    
    CGRect zoomRect;
    CGFloat newZoomScale = (self.scrollView.maximumZoomScale);
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    zoomRect.size.height = [self.imageView frame].size.height / newZoomScale;
    zoomRect.size.width  = [self.imageView frame].size.width  / newZoomScale;
    
    touchPoint = [self.scrollView convertPoint:touchPoint fromView:self.imageView];
    
    zoomRect.origin.x    = touchPoint.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = touchPoint.y - ((zoomRect.size.height / 2.0));
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark - Lifecycle

- (id)initWithMHMediaItem:(MHGalleryItem*)mediaItem
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
        self.numberFormatter = [NSNumberFormatter new];
        [self.numberFormatter setMinimumIntegerDigits:2];
        
        self.item = mediaItem;
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.delegate = self;
        self.scrollView.tag = 406;
        
        [self.scrollView setMaximumZoomScale:3];
        [self.scrollView setMinimumZoomScale:1];
        [self.scrollView setUserInteractionEnabled:YES];
        [self.view addSubview:self.scrollView];
        
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.tag = 506;
        [self.scrollView addSubview:self.imageView];
        
        self.pinch = [[MHPinchGestureRecognizer alloc]initWithTarget:self action:@selector(userDidPinch:)];
        self.pinch.delegate = self;
        
        self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(userDidPan:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        UITapGestureRecognizer *imageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        
        [self.imageView addGestureRecognizer:doubleTap];
        
        
        self.pan.delegate = self;
        if([MHGalleryDataManager sharedDataManager].animateWithCustomTransition){
            [self.imageView addGestureRecognizer:self.pan];
            [self.pan setMaximumNumberOfTouches:1];
            [self.pan setDelaysTouchesBegan:YES];
        }
        [self.scrollView addGestureRecognizer:self.pinch];
        
        [self.view addGestureRecognizer:imageTap];
        
        self.act = [[UIActivityIndicatorView alloc]initWithFrame:self.view.bounds];
        [self.act startAnimating];
        self.act.hidesWhenStopped =YES;
         self.act.tag =507;
        [self.act setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.scrollView addSubview:self.act];
        
        [self.imageView setUserInteractionEnabled:YES];
        
        [imageTap requireGestureRecognizerToFail: doubleTap];
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.item.urlString]
                                                   options:SDWebImageContinueInBackground
                                                  progress:nil
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                     if (!image) {
                                                         [self.scrollView setMaximumZoomScale:1];
                                                         [self changeToErrorImage];
                                                         
                                                     }else{
                                                         self.imageView.image = image;
                                                     }
                                                     [(UIActivityIndicatorView*)[self.scrollView viewWithTag:507] stopAnimating];
                                                 }];
    }
    
    return self;
}

#pragma mark - Viewlifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.act.color = [UIColor whiteColor];
    }else{
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.act.color = [UIColor blackColor];
    }
}

#pragma mark - Actions

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    if (![MHGalleryDataManager sharedDataManager].disableToDismissGalleryWithScrollGestureOnStartOrEndPoint) {
        if ((self.pageIndex ==0 || self.pageIndex == [MHGalleryDataManager sharedDataManager].galleryItems.count -1)) {
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")] ) {
                return YES;
            }
        }
    }
    return NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[MHPinchGestureRecognizer class]]) {
        if ([gestureRecognizer isKindOfClass:[MHPinchGestureRecognizer class]] && self.scrollView.zoomScale ==1) {
            return YES;
        }else{
            return NO;
        }
    }
    if (self.vc.isUserScrolling) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return NO;
        }
    }
    if ([gestureRecognizer isEqual:self.pan] && self.scrollView.zoomScale !=1) {
        return NO;
    }
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    if (![MHGalleryDataManager sharedDataManager].disableToDismissGalleryWithScrollGestureOnStartOrEndPoint) {
        if ((self.pageIndex ==0 || self.pageIndex == [MHGalleryDataManager sharedDataManager].galleryItems.count -1) && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            
            return YES;
        }
    }
    
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.interactiveTransition) {
        return NO;
    }
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:[MHPinchGestureRecognizer class]]) {
        return YES;
    }
    
    if (![MHGalleryDataManager sharedDataManager].disableToDismissGalleryWithScrollGestureOnStartOrEndPoint) {
        if ((self.pageIndex ==0 || self.pageIndex == [MHGalleryDataManager sharedDataManager].galleryItems.count -1) && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark UIViewControllerRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self prepareToResize];
    [self recoverFromResizing];
    [self centerImageView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration
{
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.zoomScale, self.view.bounds.size.height*self.scrollView.zoomScale);
    
    self.imageView.frame =CGRectMake(0,0 , self.scrollView.contentSize.width,self.scrollView.contentSize.height);
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews firstObject];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerImageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end

