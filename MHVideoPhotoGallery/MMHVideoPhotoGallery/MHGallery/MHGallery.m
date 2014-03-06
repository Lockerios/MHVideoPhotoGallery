
#import "MHGallery.h"
#import "MHGalleryImageViewerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWebImageDecoder.h"
#import <objc/runtime.h>

NSString * const MHGalleryViewModeOverView = @"MHGalleryViewModeOverView";
NSString * const MHGalleryViewModeShare    = @"MHGalleryViewModeShare";


NSDictionary *MHDictionaryForQueryString(NSString *string){
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	NSArray *allFieldsArray = [string componentsSeparatedByString:@"&"];
	for (NSString *fieldString in allFieldsArray){
		NSArray *pairArray = [fieldString componentsSeparatedByString:@"="];
		if (pairArray.count == 2){
			NSString *key = pairArray[0];
			NSString *value = [pairArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			dictionary[key] = value;
		}
	}
	return dictionary;
}

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


@implementation MHShareItem

- (id)initWithImageName:(NSString*)imageName
                  title:(NSString*)title
   withMaxNumberOfItems:(NSInteger)maxNumberOfItems
           withSelector:(NSString*)selectorName
       onViewController:(id)onViewController{
    self = [super init];
    if (!self)
        return nil;
    self.imageName = imageName;
    self.title = title;
    self.maxNumberOfItems = maxNumberOfItems;
    self.selectorName = selectorName;
    self.onViewController = onViewController;
    return self;
}
@end


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

-(void)defaultViewModes{
    if(!self.viewModes){
        self.viewModes = [NSSet setWithObjects:MHGalleryViewModeOverView,
                          MHGalleryViewModeShare, nil];
    }
}

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
        andCurrentViewController:(id)viewcontroller
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,MHTransitionDismissMHGallery *interactiveTransition,UIImage *image)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated{
    
    [self defaultViewModes];

    self.animateWithCustomTransition =animated;
    self.oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    self.galleryItems =galleryItems;
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    detail.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHTransitionDismissMHGallery *interactiveTransition,UIImage *image) {
        FinishBlock(galleryNavMH,photoIndex,interactiveTransition,image);
    };
    
    UINavigationController *nav = [UINavigationController new];
    if (![self.viewModes containsObject:MHGalleryViewModeOverView] || galleryItems.count ==1) {
        nav.viewControllers = @[detail];
    }else{

    }
    if (animated) {
        if (MHiOS7) {
            nav.transitioningDelegate = viewcontroller;
        }
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [viewcontroller presentViewController:nav animated:YES completion:nil];
}
-(void)getImageFromAssetLibrary:(NSString*)urlString
                      assetType:(MHAssetImageType)type
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        ALAssetsLibrary *assetslibrary = [ALAssetsLibrary new];
        [assetslibrary assetForURL:[NSURL URLWithString:urlString]
                       resultBlock:^(ALAsset *asset){
                           
                           if (type == MHAssetImageTypeThumb) {
                               dispatch_sync(dispatch_get_main_queue(), ^(void){
                                   UIImage *image = [[UIImage alloc]initWithCGImage:asset.thumbnail];
                                   succeedBlock(image,nil);
                               });
                           }else{
                               ALAssetRepresentation *rep = [asset defaultRepresentation];
                               CGImageRef iref = [rep fullScreenImage];
                               if (iref) {
                                   dispatch_sync(dispatch_get_main_queue(), ^(void){
                                       UIImage *image = [[UIImage alloc]initWithCGImage:iref];
                                       succeedBlock(image,nil);
                                   });
                               }
                           }
                       }
                      failureBlock:^(NSError *error) {
                          dispatch_sync(dispatch_get_main_queue(), ^(void){
                              succeedBlock(nil,error);
                          });
                      }];
    });
}



-(BOOL)isUIVCBasedStatusBarAppearance{
    NSNumber *isUIVCBasedStatusBarAppearance = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isUIVCBasedStatusBarAppearance) {
        return  isUIVCBasedStatusBarAppearance.boolValue;
    }
    return YES;
}

-(void)createThumbURL:(NSString*)urlString
         successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock{
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
    if (!dict) {
        dict = [NSMutableDictionary new];
    }
    if (image) {
        succeedBlock(image,[dict[urlString] integerValue],nil);
    }else{
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//            NSURL *url = [NSURL URLWithString:urlString];
//            AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
//            
//            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//            CMTime thumbTime = CMTimeMakeWithSeconds(0,40);
//            CMTime videoDurationTime = asset.duration;
//            NSUInteger videoDurationTimeInSeconds = CMTimeGetSeconds(videoDurationTime);
//            
//            NSMutableDictionary *dictToSave = [self durationDict];
//            if (videoDurationTimeInSeconds !=0) {
//                dictToSave[urlString] = @(videoDurationTimeInSeconds);
//                [self setObjectToUserDefaults:dictToSave];
//            }
//            if(self.webPointForThumb == MHWebPointForThumbStart){
//                thumbTime = CMTimeMakeWithSeconds(0,40);
//            }else if(self.webPointForThumb == MHWebPointForThumbMiddle){
//                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds/2,40);
//            }else if(self.webPointForThumb == MHWebPointForThumbEnd){
//                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds,40);
//            }
//            
//            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
//                
//                if (result != AVAssetImageGeneratorSucceeded) {
//                    dispatch_async(dispatch_get_main_queue(), ^(void){
//                        succeedBlock(nil,0,error);
//                    });
//                }else{
//                    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithCGImage:im]
//                                                         forKey:urlString];
//                    dispatch_async(dispatch_get_main_queue(), ^(void){
//                        succeedBlock([UIImage imageWithCGImage:im],videoDurationTimeInSeconds,nil);
//                    });
//                }
//            };
//            if (self.webThumbQuality == MHWebThumbQualityHD720) {
//                generator.maximumSize = CGSizeMake(720, 720);
//            }else if (self.webThumbQuality == MHWebThumbQualityMedium) {
//                generator.maximumSize = CGSizeMake(420 ,420);
//            }else if(self.webThumbQuality == MHWebThumbQualitySmall) {
//                generator.maximumSize = CGSizeMake(220 ,220);
//            }
//            [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
//                                            completionHandler:handler];
//        });
    }
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
        customAnimationFromImage:(BOOL)animated{
    
    [[MHGalleryDataManager sharedDataManager] defaultViewModes];
    
    [MHGalleryDataManager sharedDataManager].animateWithCustomTransition =animated;
    [MHGalleryDataManager sharedDataManager].oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [MHGalleryDataManager sharedDataManager].galleryItems =galleryItems;
    
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


