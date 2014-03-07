
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "MHDismissMHGalleryTransition.h"
#import "MHPresentMHGalleryTransition.h"

#define kMHGalleryBundleName @"MHGallery.bundle"

#define MHiOS7 ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)

@class MHDismissMHGalleryTransition;
@class MHPresentMHGalleryTransition;
@class MHPresenterImageView;

extern void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize));
extern void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName));

extern NSBundle *MHGalleryBundle(void);
extern NSString *MHGalleryLocalizedString(NSString *localizeString);
extern UIImage  *MHGalleryImage(NSString *imageName);

@interface MHGalleryItem : NSObject

@property (nonatomic,strong) NSString           *urlString;
@property (nonatomic,strong) NSString           *description;
@property (nonatomic,strong) NSAttributedString *attributedString;

/**
 *  MHGalleryItem
 *
 *  @param urlString   the URL of the image or Video as a String
 *  @param galleryType select to Type, video or image
 *
 */

- (id)initWithURL:(NSString*)urlString;

@end

@interface MHGalleryDataManager : NSObject

/**
 *  By default the gallery will dismiss itself by scrolling to left at the pageIndex of 0 or scrolling right at the last pageindex here you can disbale it.
 */
@property (nonatomic)       BOOL disableToDismissGalleryWithScrollGestureOnStartOrEndPoint;

/**
 *  By default the X Value is considered by dismissing the Gallery. You can disable it here.
 */
@property (nonatomic)       BOOL shouldFixXValueForDismissMHGallery;
/**
 *  sets the TintColor for the NavigationBar and the ToolBar
 */
@property (nonatomic,strong) UIColor *barColor;

@property (nonatomic,strong) NSArray *galleryItems;
@property (nonatomic,assign) UIStatusBarStyle oldStatusBarStyle;
@property (nonatomic,assign) BOOL animateWithCustomTransition;

+ (MHGalleryDataManager *)sharedDataManager;

- (UIImage *)imageByRenderingView:(id)view;

@end

@interface UIViewController(MHGalleryViewController)<UIViewControllerTransitioningDelegate>


/**
 *  Use this Methode to Present to MHGallery. If you want to animate it set the 'ivForPresentingAndDismissingMHGallery' from which you are presenting. In the FinishBlock you have to set ‘ivForPresentingAndDismissingMHGallery‘ again with the new ImageView.
 *
 *  @param galleryItems items you want to present
 *  @param index        index from which you want to present
 *  @param FinishBlock  returns the UINavigationController the currentPageIndex and the Image
 *  @param animated     if you want the custom transition set it to Yes.
 */
-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                   fromImageView:(UIImageView*)fromImageView
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHDismissMHGalleryTransition *interactiveDismissMHGallery)
                                  )FinishBlock
                        customAnimationFromImage:(BOOL)animated;

- (void)dismissViewControllerAnimated:(BOOL)flag
                     dismissImageView:(UIImageView*)dismissImageView
                           completion:(void (^)(void))completion;

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                   fromImageView:(UIImageView*)fromImageView
        withInteractiveTranstion:(MHPresentMHGalleryTransition*)presentInteractive
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHDismissMHGalleryTransition *interactiveDismissMHGallery)
                                  )FinishBlock
        customAnimationFromImage:(BOOL)animated;

@end

