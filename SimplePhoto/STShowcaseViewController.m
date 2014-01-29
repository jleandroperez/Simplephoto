//
//  STShowcaseViewController.m
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "STShowcaseViewController.h"
#import "STShowcaseViewCell.h"
#import "STAppDelegate.h"
#import "Snapshot.h"

#import "UIImage+Extensions.h"



#pragma mark ================================================================================================
#pragma mark Constants
#pragma mark ================================================================================================

static CGFloat const STSnapshotMaxWidth						= 1024;
static CGFloat const STSnapshotQuality						= 0.8;
static CGFloat const STShowcaseAnimationDuration			= 0.3f;
static CGFloat const STShowcaseAnimationAlphaTranslucent	= 0.0f;
static CGFloat const STShowcaseAnimationAlphaDark			= 1.0f;


#pragma mark ================================================================================================
#pragma mark Private Methods
#pragma mark ================================================================================================

@interface STShowcaseViewController ()
@property (nonatomic, weak, readwrite) IBOutlet UICollectionView	*collectionView;
@property (nonatomic, strong, readwrite) NSFetchedResultsController	*fetchedResultsController;
@property (nonatomic, strong, readwrite) NSBlockOperation			*blockOperation;
@end

@interface STShowcaseViewController (CollectionViewDelegate) <UICollectionViewDataSource>
@end

@interface STShowcaseViewController (FetchedResultsDelegate) <NSFetchedResultsControllerDelegate>
@end

@interface STShowcaseViewController (ImagePickerDelegate) <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end


#pragma mark ================================================================================================
#pragma mark STShowcaseViewController
#pragma mark ================================================================================================

@implementation STShowcaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.title = NSLocalizedString(@"SimplePhoto", nil);
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
																						   target:self
																						   action:@selector(btnCameraPressed:)];
}

- (void)btnCameraPressed:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.allowsEditing = NO;
	[self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark ================================================================================================
#pragma mark UIImagePickerControllerDelegate
#pragma mark ================================================================================================

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
{
	// Resize Image
	CGSize imageSize				= selectedImage.size;
	CGSize newSize					= CGSizeMake(STSnapshotMaxWidth, roundf( STSnapshotMaxWidth * imageSize.height / imageSize.width ) );
	UIImage *fixedOrientation		= [selectedImage scaleToSize:newSize];

	NSData *serialized				=  UIImageJPEGRepresentation(fixedOrientation, STSnapshotQuality);

	// Save!
	NSManagedObjectContext *context = [[STAppDelegate sharedDelegate] managedObjectContext];
	
	Snapshot *snapshot				= (Snapshot *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Snapshot class]) inManagedObjectContext:context];
	snapshot.picture				= serialized;
	snapshot.date					= [NSDate date];

	[[STAppDelegate sharedDelegate] saveContext];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ================================================================================================
#pragma mark UICollectionViewDataSource
#pragma mark ================================================================================================

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Snapshot *snapshot = (Snapshot *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	NSString *identifier = NSStringFromClass([STShowcaseViewCell class]);
	STShowcaseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.imageView.image = [[UIImage alloc] initWithData:snapshot.picture];
	
	return cell;
}


#pragma mark ================================================================================================
#pragma mark UICollectionViewDelegate
#pragma mark ================================================================================================

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	STShowcaseViewCell *cell				= (STShowcaseViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
	// Detect Swipe in any direction + Tap
	UITapGestureRecognizer *tapGR			= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDismissPressed:)];
	tapGR.numberOfTapsRequired				= 1;
	
	UISwipeGestureRecognizer *horizontalGR	= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnDismissPressed:)];
	horizontalGR.direction					= UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
	
	UISwipeGestureRecognizer *verticalGR	= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnDismissPressed:)];
	verticalGR.direction					= UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
	
	// Load the imageView
	UIImageView *imageView					= [[UIImageView alloc] initWithImage:cell.imageView.image];
	imageView.contentMode					= UIViewContentModeScaleAspectFit;
	imageView.frame							= self.view.bounds;
	
	// Wrap this up with a fullscreen view
	UIView *fullscreenView					= [[UIView alloc] initWithFrame:self.view.bounds];
	fullscreenView.userInteractionEnabled	= YES;
	fullscreenView.gestureRecognizers		= @[ tapGR, horizontalGR, verticalGR ];
	fullscreenView.backgroundColor			= [UIColor blackColor];
	fullscreenView.alpha					= STShowcaseAnimationAlphaTranslucent;
	[fullscreenView addSubview:imageView];
	
	[self.view.window addSubview:fullscreenView];
	
	// Animate!
	[UIView animateWithDuration:STShowcaseAnimationDuration animations:^{
		fullscreenView.alpha	= STShowcaseAnimationAlphaDark;
	}];
}

- (void)btnDismissPressed:(UIGestureRecognizer *)gr
{
	UIView *fullscreenView = gr.view;
	
	[UIView animateWithDuration:STShowcaseAnimationDuration animations:^{
		fullscreenView.alpha = STShowcaseAnimationAlphaTranslucent;
	} completion:^(BOOL finished) {
		[fullscreenView removeFromSuperview];
	}];
}


#pragma mark ================================================================================================
#pragma mark Fetched results controller
#pragma mark ================================================================================================

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
	{
        return _fetchedResultsController;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [[STAppDelegate sharedDelegate] managedObjectContext];
	
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([Snapshot class]) inManagedObjectContext:context];
    fetchRequest.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] ];
	
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
	
    return _fetchedResultsController;
}


#pragma mark ================================================================================================
#pragma mark Fetched results controller
#pragma mark ================================================================================================

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
	[self.blockOperation addExecutionBlock:^{
		[collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
	}];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^{
        [self.blockOperation start];
    } completion:^(BOOL finished) {
		// Something?
    }];
}

@end
