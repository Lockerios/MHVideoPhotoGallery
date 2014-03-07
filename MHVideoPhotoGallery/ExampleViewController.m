//
//  ExampleViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.09.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "ExampleViewController.h"
#import "MHGalleryImageViewerViewController.h"
#import "MHGalleryCells.h"

#import "MHGalleryView.h"

@implementation UINavigationController (autoRotate)

- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end

@interface ExampleViewController ()
@property(nonatomic,strong) NSArray *galleryDataSource;
@end

@implementation ExampleViewController

#pragma mark - Methods

- (void)makeOverViewDetailCell:(MHGalleryViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"makeOverViewDetailCell called: %ld",(long)indexPath.row);
    
    MHGalleryItem *item = self.galleryDataSource[indexPath.section][indexPath.row];
    
    [cell.thumbnail setContentMode:UIViewContentModeScaleAspectFill];
    
    cell.thumbnail.layer.shadowOffset = CGSizeMake(0, 0);
    cell.thumbnail.layer.shadowRadius = 1.0;
    cell.thumbnail.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.thumbnail.layer.shadowOpacity = 0.5;
    cell.thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.thumbnail.bounds].CGPath;
    cell.thumbnail.layer.cornerRadius = 2.0;
    
    cell.thumbnail.image = nil;
    [cell.thumbnail setImageWithURL:[NSURL URLWithString:item.urlString]];
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.title = @"CollectionInTable";
   
    MHGalleryItem *landschaft = [[MHGalleryItem alloc]initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(47).jpg"];
    
    MHGalleryItem *landschaft1 = [[MHGalleryItem alloc]initWithURL:@"http://de.flash-screen.com/free-wallpaper/bezaubernde-landschaftsabbildung-hd/hd-bezaubernde-landschaftsder-tapete,1920x1200,56420.jpg"];
    
    MHGalleryItem *landschaft2 = [[MHGalleryItem alloc]initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(64).jpg"];
    
    MHGalleryItem *landschaft3 = [[MHGalleryItem alloc]initWithURL:@"http://www.dirks-computerseite.de/wp-content/uploads/2013/06/purpleworld1.jpg"];
    
    MHGalleryItem *landschaft4 = [[MHGalleryItem alloc]initWithURL:@"http://alles-bilder.de/landschaften/HD%20Landschaftsbilder%20(42).jpg"];
    
    MHGalleryItem *landschaft5 = [[MHGalleryItem alloc]initWithURL:@"http://woxx.de/wp-content/uploads/sites/3/2013/02/8X2cWV3.jpg"];
    
    MHGalleryItem *landschaft6 = [[MHGalleryItem alloc]initWithURL:@"http://kwerfeldein.de/wp-content/uploads/2012/05/Sharpened-version.jpg"];
    
    MHGalleryItem *landschaft7 = [[MHGalleryItem alloc]initWithURL:@"http://eswalls.com/wp-content/uploads/2014/01/sunset-glow-trees-beautiful-scenery.jpg"];
    
    MHGalleryItem *landschaft8 = [[MHGalleryItem alloc]initWithURL:@"http://eswalls.com/wp-content/uploads/2014/01/beautiful_scenery_wallpaper_The_Eiffel_Tower_at_night_.jpg"];
    
    MHGalleryItem *landschaft9 = [[MHGalleryItem alloc]initWithURL:@"http://p1.pichost.me/i/40/1638707.jpg"];
    
    MHGalleryItem *landschaft10 = [[MHGalleryItem alloc]initWithURL:@"http://4.bp.blogspot.com/-8O0ZkAgb6Bo/Ulf_80tUN6I/AAAAAAAAH34/I1L2lKjzE9M/s1600/Beautiful-Scenery-Wallpapers.jpg"];

//    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"Awesome!!\nOr isn't it?"];
//    
//    [string setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} range:NSMakeRange(0, string.length)];
//    [string setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]} range:NSMakeRange(0, 9)];
//    
//    landschaft10.attributedString = string;
    
    self.galleryDataSource = @[@[landschaft10,landschaft8,landschaft7,landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1,landschaft10,landschaft8,landschaft7,landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1,landschaft10,landschaft8,landschaft7,landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1],
                               @[landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft,landschaft1],
                               @[landschaft9,landschaft6,landschaft5,landschaft4,landschaft3,landschaft2,landschaft],
                               @[landschaft9,landschaft6,landschaft5,landschaft4,landschaft3],
                               @[landschaft9,landschaft6,landschaft5,landschaft4],
                               @[landschaft9,landschaft6,landschaft5],
                               @[landschaft9,landschaft6],
                               @[landschaft9]
                               ];
    
    MHGalleryView* view = [[MHGalleryView alloc] initWithFrame:self.view.frame];
    view.delegate = self;
    [view updateData];
    
    [self.view addSubview:view];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Actions

#pragma mark MHGalleryViewDelegate

#pragma mark UITableView

- (NSInteger)numberOfRowsInSectionInMHTable
{
    return 1;
}

- (NSInteger)numberOfSectionsInMHTable
{
    return [_galleryDataSource count];
}

- (CGFloat)heightForRowAtIndexPathInMHTable:(NSIndexPath *)indexPath
{
    return 330;
}

- (UITableViewCell *)cellForRowAtIndexPathInMHTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath reuseCellIdentifier:(NSString *)identifier reuseCollectionIdentifier:(NSString *)cIdentifier inMH:(MHGalleryView *)galleryView
{
    MHGalleryTableViewCell *cell = (MHGalleryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell){
        cell = [[MHGalleryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 330)];
        
        cell.backView.layer.masksToBounds = NO;
        cell.backView.layer.shadowOffset = CGSizeMake(0, 0);
        cell.backView.layer.shadowRadius = 1.0;
        cell.backView.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.backView.layer.shadowOpacity = 0.5;
        cell.backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.backView.bounds].CGPath;
        cell.backView.layer.cornerRadius = 2.0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
        layout.itemSize = CGSizeMake(270, 225);
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        cell.collectionView = [[UICollectionView alloc] initWithFrame:cell.bounds collectionViewLayout:layout];
        cell.collectionView.backgroundColor = [UIColor clearColor];
        
        [cell.collectionView registerClass:[MHGalleryViewCell class] forCellWithReuseIdentifier:cIdentifier];
        
        cell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [cell.collectionView setShowsHorizontalScrollIndicator:NO];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:cell.backView];
        [cell.contentView addSubview:cell.collectionView];
    }
    
    [cell.collectionView setDelegate:galleryView];
    [cell.collectionView setDataSource:galleryView];
    [cell.collectionView setTag:indexPath.section];
    [cell.collectionView reloadData];
    
    return cell;
}

#pragma mark UICollectionView

- (NSInteger)numberOfSectionsInCollectionView
{
    return 1;
}

- (NSInteger)numberOfCellInCollectionViewWithTag:(NSInteger)collectionTag
{
    NSLog(@"numberOfCellInCollectionViewWithTag: %ld",(long)[self.galleryDataSource[collectionTag] count]);
    
    return [self.galleryDataSource[collectionTag] count];
}

-(UICollectionViewCell *)cellForItemAtIndexPathInMHCollection:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath reuseCellIdentifier:(NSString *)identifier
{
    UICollectionViewCell *cell =nil;
    cell = [collection dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row inSection:collection.tag];
    [self makeOverViewDetailCell:(MHGalleryViewCell*)cell atIndexPath:indexPathNew];
    
    return cell;
}

- (void)galleryViewDidTapImageView:(UIImageView *)imageView forRow:(NSInteger)row inView:(UICollectionView *)view
{
    [self presentMHGalleryWithItems:self.galleryDataSource[view.tag]
                           forIndex:row
                      fromImageView:imageView
                     finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image,MHDismissMHGalleryTransition *interactiveDismissMHGallery) {
                         NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:pageIndex inSection:0];
                         CGRect cellFrame  = [[view collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
                         [view scrollRectToVisible:cellFrame
                                                    animated:NO];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [view reloadItemsAtIndexPaths:@[newIndexPath]];
                             [view scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                             
                             MHGalleryViewCell *cell = (MHGalleryViewCell*)[view cellForItemAtIndexPath:newIndexPath];
                             
                             [galleryNavMH dismissViewControllerAnimated:YES dismissImageView:cell.thumbnail completion:^{}];
                         });
                         
                     } customAnimationFromImage:YES];
}

@end
