//
//  ViewController.m
//  suckapunch
//
//  Created by Keith Elliott on 12/4/12.
//  Copyright (c) 2012 Keith Elliott. All rights reserved.
//

#import "ViewController.h"
#import "UIView+UIView_Utils.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()
extern const int PROGRESS_VIEW;
extern const int FILTER_VIEW;
@end

@implementation ViewController
@synthesize PhotoView;
@synthesize imageContext;
const int PROGRESS_VIEW = 2000;
const int FILTER_VIEW = 3000;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
		// create and add a background to view
	UIImage *background;
	imageContext = [CIContext contextWithOptions:nil];

	if(self.view.hasFourInchDisplay){
		background = [UIImage imageNamed:@"Default-568h.png"];
	}
	else{
		background = [UIImage imageNamed:@"Default.png"];
	}
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:background];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideFilterView {
	[self.view sendSubviewToBack:[self.view viewWithTag:FILTER_VIEW]];
	[self.view viewWithTag:FILTER_VIEW].alpha = 0;
}

- (void)hideProgressView {
	[self.view sendSubviewToBack:[self.view viewWithTag:PROGRESS_VIEW]];
	[self.view viewWithTag:PROGRESS_VIEW].alpha = 0;
}

-(void)viewDidAppear:(BOOL)animated{
	[self hideProgressView];	
	[self hideFilterView];
}

-(void)showPhotoLibrary{
	
	if(self.view.isCameraAvailable && self.view.doesCameraSupportTakingPhotos){
		UIImagePickerController *pc;
		pc = [[UIImagePickerController alloc]init];
		[pc setSourceType:UIImagePickerControllerSourceTypeCamera];
		NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
		pc.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
		pc.allowsEditing = YES;
		[pc setDelegate:self];
		[self.navigationController presentViewController:pc animated:YES completion:nil];
	}
	else{
		NSLog(@"Camera is not available");
	}
}

- (IBAction)punchAction:(id)sender {
	self.PhotoView.image = nil;
	[self showPhotoLibrary];
}

-(void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
	
	if(paramError == nil){
		NSLog(@"Image was saved successfully");
	}else{
		NSLog(@"An erro happened while saving the image");
		NSLog(@"Error = %@", paramError);
	}
}

- (void)showProgressView {
    [self.view bringSubviewToFront:[self.view viewWithTag:PROGRESS_VIEW]];
	[self.view viewWithTag:PROGRESS_VIEW].alpha = 1;
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	NSLog(@"picker returned successfully");
	
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]){
		NSURL *urlOfVideo = [info objectForKey:UIImagePickerControllerMediaURL];
		
		NSLog(@"Video URL = %@", urlOfVideo);
	}
	
	else if([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){
		NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
		
		UIImage *theImage; 
			//theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		
		if([picker allowsEditing]){
			theImage = [info objectForKey:UIImagePickerControllerEditedImage];
		}
		else{
			theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		}
		
		NSLog(@"Image Metadata = %@", metadata);
		NSLog(@"Image = %@", theImage);
		
		SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
		
		UIImageWriteToSavedPhotosAlbum(theImage, self, selectorToCall, NULL);
		NSLog(@"image- height: %f  width: %f", theImage.size.height, theImage.size.width);
		
		[self displayPhoto:theImage];
	}
	
	[self showProgressView];
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	NSLog(@"Picker was cancelled");
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)displayPhoto:(UIImage *)photo{
	self.PhotoView.image = photo;
	[self detectFaces];
}

-(CIImage*)makeBoxForFace:(CIFaceFeature*)face{
	CIColor *color = [CIColor colorWithRed:0 green:0 blue:1 alpha:.33];
	CIImage *image = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", color, nil].outputImage;
	
	image = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, image, @"inputRectangle",[CIVector vectorWithCGRect:face.bounds], nil].outputImage;
	return image;
}


- (void)showFilterView {
    [self.view bringSubviewToFront:[self.view viewWithTag:FILTER_VIEW]];
    [self.view viewWithTag:FILTER_VIEW].alpha = 1;
}

-(void)updateFaceBoxes{
	
	CIImage *coreImage = [CIImage imageWithCGImage:PhotoView.image.CGImage];
	
		// Set up desired accuracy options dictionary
	NSDictionary *options = [NSDictionary
													 dictionaryWithObject:CIDetectorAccuracyHigh
													 forKey:CIDetectorAccuracy];
	
		// Create new CIDetector
	CIDetector *faceDetector = [CIDetector
															detectorOfType:CIDetectorTypeFace
															context:self.imageContext
															options:options];
	
	NSArray *faces = [faceDetector featuresInImage:coreImage
																				 options:nil];
	
	for(CIFaceFeature *face in faces){
		coreImage = [CIFilter filterWithName:@"CISourceOverCompositing"
													 keysAndValues:kCIInputImageKey, [self makeBoxForFace:face],
								 kCIInputBackgroundImageKey, coreImage, nil].outputImage;
	}
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	dispatch_async(dispatch_get_main_queue(), ^(void){
		self.PhotoView.image = [UIImage imageWithCGImage:cgImage];
		[self hideProgressView];
		[self showFilterView];

	});
}

- (void)detectFaces {
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self updateFaceBoxes];
								 });
	
}

-(UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize{
	CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
	CGImageRef imageRef = image.CGImage;
	
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
	
	CGContextConcatCTM(context, flipVertical);
	CGContextDrawImage(context, newRect, imageRef);
	
	CGImageRef newImageRef = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	
	CGImageRelease(newImageRef);
	UIGraphicsEndImageContext();
	
	return newImage;
}
@end
