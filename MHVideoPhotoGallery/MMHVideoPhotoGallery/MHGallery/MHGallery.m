
#import "MHGallery.h"
#import "MHGalleryImageViewerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWebImageDecoder.h"
#import <objc/runtime.h>

NSBundle *MHGalleryBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kMHGalleryBundleName];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

static NSString* (^ CustomLocalizationBlock)(NSString *localization) = nil;
static UIImage* (^ CustomImageBlock)(NSString *imageToChangeName) = nil;

void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName)){
    CustomImageBlock = customImageBlock;
}
void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize)){
    CustomLocalizationBlock = customLocalizationBlock;
}

NSString *MHGalleryLocalizedString(NSString *localizeString) {
    if (CustomLocalizationBlock) {
        NSString *string = CustomLocalizationBlock(localizeString);
        if (string) {
            return string;
        }
    }
    return  NSLocalizedStringFromTableInBundle(localizeString, @"MHGallery", MHGalleryBundle(), @"");
}


UIImage *MHGalleryImage(NSString *imageName){
    if (CustomImageBlock) {
        UIImage *changedImage = CustomImageBlock(imageName);
        if (changedImage) {
            return changedImage;
        }
    }
    return [UIImage imageNamed:imageName];
}


@implementation MHGalleryItem


- (id)initWithURL:(NSString*)urlString{
    self = [super init];
    if (!self)
        return nil;
    self.urlString = urlString;
    self.description = nil;
    self.attributedString = nil;
    return self;
}
@end


@implementation MHGalleryDataManager

+ (MHGalleryDataManager *)sharedDataManager{
    static MHGalleryDataManager *sharedManagerInstance = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

-(NSString*)languageIdentifier{
	static NSString *applicationLanguageIdentifier;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		applicationLanguageIdentifier = @"en";
		NSArray *preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
		if (preferredLocalizations.count > 0)
			applicationLanguageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:preferredLocalizations[0]] ?: applicationLanguageIdentifier;
	});
	return applicationLanguageIdentifier;
}

-(void)setObjectToUserDefaults:(NSMutableDictionary*)dict{
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"MHGalleryData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(NSMutableDictionary*)durationDict{
    return [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
}

- (UIImage *)imageByRenderingView:(id)view{
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    if(scale > 1.5) {
        UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, scale);
    } else {
        UIGraphicsBeginImageContext([view bounds].size);
    }
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end

@implementation UIViewController(MHGalleryViewController)

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                   fromImageView:(UIImageView*)fromImageView
        withInteractiveTranstion:(MHTransitionPresentMHGallery*)presentInteractive
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveDismissMHGallery)
                                  )FinishBlock
        customAnimationFromImage:(BOOL)animated
{
    [MHGalleryDataManager sharedDataManager].animateWithCustomTransition = animated;
    [MHGalleryDataManager sharedDataManager].oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [MHGalleryDataManager sharedDataManager].galleryItems = galleryItems;
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.interactivePresentationTranstion = presentInteractive;
    detail.pageIndex = index;
    detail.presentingFromImageView = fromImageView;
    detail.finishedCallback = ^(UINavigationController *galleryNavMH,
                                NSUInteger photoIndex,
                                MHTransitionDismissMHGallery *interactiveTransition,
                                UIImage *image) {
        FinishBlock(galleryNavMH,photoIndex,image,interactiveTransition);
    };
    
    UINavigationController *nav = [UINavigationController new];
    
    nav.viewControllers = @[detail];
    
    if (animated) {
        if (MHiOS7) {
            nav.transitioningDelegate = self;
        }
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                   fromImageView:(UIImageView*)fromImageView
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition)
                                  )FinishBlock
        customAnimationFromImage:(BOOL)animated{
    
    [self presentMHGalleryWithItems:galleryItems
                           forIndex:index
                      fromImageView:fromImageView
           withInteractiveTranstion:nil
                     finishCallback:FinishBlock
           customAnimationFromImage:animated];
}

- (void)dismissViewControllerAnimated:(BOOL)flag dismissImageView:(UIImageView*)dismissImageView completion:(void (^)(void))completion{
    if ([[(UINavigationController*)self viewControllers].lastObject isKindOfClass:[MHGalleryImageViewerViewController class]]) {
        MHGalleryImageViewerViewController *imageViewer = [(UINavigationController*)self viewControllers].lastObject;
        imageViewer.dismissFromImageView = dismissImageView;
    }
    [self dismissViewControllerAnimated:flag completion:completion];
}


-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:[MHTransitionPresentMHGallery class]]) {
        MHTransitionPresentMHGallery *animatorPresent = (MHTransitionPresentMHGallery*)animator;
        if (animatorPresent.interactive) {
            return animatorPresent;
        }
        return nil;
    }else {
        return nil;
    }
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:[MHTransitionDismissMHGallery class]]) {
        MHTransitionDismissMHGallery *animatorDismiss = (MHTransitionDismissMHGallery*)animator;
        if (animatorDismiss.interactive) {
            return animatorDismiss;
        }
        return nil;
    }else {
        return nil;
    }
}


-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if ([[(UINavigationController*)dismissed  viewControllers].lastObject isKindOfClass:[MHGalleryImageViewerViewController class]]) {
        MHGalleryImageViewerViewController *imageViewer = [(UINavigationController*)dismissed  viewControllers].lastObject;
        ImageViewController *viewer = imageViewer.pvc.viewControllers.firstObject;
        if (viewer.interactiveTransition) {
            MHTransitionDismissMHGallery *detail = viewer.interactiveTransition;
            detail.transitionImageView = imageViewer.dismissFromImageView;
            return detail;
        }
        MHTransitionDismissMHGallery *detail = [MHTransitionDismissMHGallery new];
        detail.transitionImageView = imageViewer.dismissFromImageView;
        return detail;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    UINavigationController *nav = (UINavigationController*)presented;
    if ([nav.viewControllers.lastObject  isKindOfClass:[MHGalleryImageViewerViewController class]]) {
        MHGalleryImageViewerViewController *imageViewer = nav.viewControllers.lastObject;
        
        if (imageViewer.interactivePresentationTranstion) {
            MHTransitionPresentMHGallery *detail = imageViewer.interactivePresentationTranstion;
            detail.presentingImageView = imageViewer.presentingFromImageView;
            return detail;
        }
        MHTransitionPresentMHGallery *detail = [MHTransitionPresentMHGallery new];
        detail.presentingImageView = imageViewer.presentingFromImageView;
        return detail;
    }
    return nil;
}

@end


