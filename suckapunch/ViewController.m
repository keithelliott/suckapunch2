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
#import <Social/Social.h>

@interface ViewController ()
extern const int PROGRESS_VIEW;
extern const int FILTER_VIEW;
extern const int FILTER_VIEW_BORDER;
extern const int ACTIVE_FILTER_VIEW;
extern const int ADD_BTN;
extern const int MINUS_BTN;
extern const float RESIZE_MULTIPLIER;

@end

@implementation ViewController
@synthesize PhotoView;
@synthesize imageContext;
const int PROGRESS_VIEW = 2000;
const int FILTER_VIEW = 3000;
const int FILTER_VIEW_BORDER = 3001;
const int ADD_BTN = 3002;
const int MINUS_BTN = 3003;
const int ACTIVE_FILTER_VIEW = 2500;
const float RESIZE_MULTIPLIER = 0.1;
BOOL dragging = NO;
CGFloat oldY;
CGFloat oldX;
BOOL filterSelected = NO;

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
	[self initFilterView];
	[self hideFilterView];
	[self hideProgressView];
	[self hideFilterButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideFilterView {
	[self.view viewWithTag:FILTER_VIEW].alpha = 0;
	[self.view viewWithTag:FILTER_VIEW_BORDER].alpha = 0;
}

- (void)hideProgressView {
	[self.view sendSubviewToBack:[self.view viewWithTag:PROGRESS_VIEW]];
	[self.view viewWithTag:PROGRESS_VIEW].alpha = 0;
}

- (void)showFilterButtons{
	[self.view viewWithTag:ADD_BTN].alpha = 1;
	[self.view viewWithTag:MINUS_BTN].alpha = 1;
	self.resetBtn.alpha = 1;
	self.opacitySlider.alpha = 1;
}

- (void)hideFilterButtons{
	[self.view viewWithTag:ADD_BTN].alpha = 0;
	[self.view viewWithTag:MINUS_BTN].alpha = 0;
	self.resetBtn.alpha = 0;
	self.opacitySlider.alpha = 0;
}

- (void)showFilterView {
	[self.view viewWithTag:FILTER_VIEW_BORDER].alpha = 1;
	[self.view viewWithTag:FILTER_VIEW].alpha = 1;
	
}

- (void)showProgressView {
	[self.view bringSubviewToFront:[self.view viewWithTag:PROGRESS_VIEW]];
	[self.view viewWithTag:PROGRESS_VIEW].alpha = 1;
}

-(void)showPhotoLibrary{	
	if(self.view.isCameraAvailable && self.view.doesCameraSupportTakingPhotos){
		UIImagePickerController *pc;
		pc = [[UIImagePickerController alloc]init];
		[pc setSourceType:UIImagePickerControllerSourceTypeCamera];
		NSString *requiredMediaType = (__bridge NSString *)kUTTypeImage;
		pc.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
		pc.allowsEditing = NO;
		[pc setDelegate:self];
		[self.navigationController presentViewController:pc animated:YES completion:nil];
	}
	else{
		NSLog(@"Camera is not available");
	}
}

- (void)processPunchAction {
    self.PhotoView.image = nil;
	[self hideProgressView];
	[self hideFilterView];
	[self hideFilterButtons];
	[self showPhotoLibrary];
	[[self.view viewWithTag:ACTIVE_FILTER_VIEW] removeFromSuperview];
	[self.view viewWithTag:ACTIVE_FILTER_VIEW].tag = 0;
}

- (IBAction)punchAction:(id)sender {
	
	if(self.PhotoView.image != nil){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
					message:@"Are you sure you want to take another picture? Your existing photo will be lost.  Consider sending it or saving to your photo library" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
			
			[alert show];
	}
	else
		[self processPunchAction];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex > 0){
		[self processPunchAction];
	}
}


-(void)hideUI{
	self.facebook.alpha = 0;
	self.email.alpha = 0;
	self.tabbar.alpha = 0;
	self.twitter.alpha = 0;
	self.library.alpha = 0;
	self.punchBtn.alpha = 0;
	self.plus.alpha = 0;
	self.minus.alpha = 0;

	
	[self hideProgressView];
	[self hideFilterView];
	[self hideFilterButtons];
}

-(void)showUI{
	self.facebook.alpha = 1;
	self.email.alpha = 1;
	self.tabbar.alpha = 1;
	self.twitter.alpha = 1;
	self.library.alpha = 1;
	self.punchBtn.alpha = 1;
	self.plus.alpha = 1;
	self.minus.alpha = 1;
  [self showFilterView];
	[self showFilterButtons];
}

- (UIImage *)createImageScreenShot {
	[self hideUI];
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - self.tabbar.bounds.size.height);
	UIGraphicsBeginImageContextWithOptions(size, self.view.opaque, 0.0);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *photo = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[self showUI];
	
	return photo;
}

-(void)saveImageToLibary{	
	UIImage *photo;
    photo = [self createImageScreenShot];
	
	SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
	UIImageWriteToSavedPhotosAlbum(photo, self, selectorToCall, NULL);
	[self hideFilterButtons];
}

-(void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
	
	if(paramError == nil){
		NSLog(@"Image was saved successfully");
	}else{
		NSLog(@"An erro happened while saving the image");
		NSLog(@"Error = %@", paramError);
	}
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	
	[self hideFilterView];
	[controller dismissViewControllerAnimated:YES completion:nil];
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
		
		if([picker allowsEditing]){
			theImage = [info objectForKey:UIImagePickerControllerEditedImage];
		}
		else{
			theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		}

		UIGraphicsBeginImageContext(theImage.size);
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(currentContext, theImage.size.width, 0);
		CGContextScaleCTM(currentContext, -1.0, 1.0);
		[theImage drawInRect:CGRectMake(0, 0, theImage.size.width, theImage.size.height)];
		
		UIImage* flippedFrame = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		NSLog(@"Image Metadata = %@", metadata);
		NSLog(@"Image = %@", theImage);
		
		[self displayPhoto:flippedFrame];
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	NSLog(@"Picker was cancelled");
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)displayPhoto:(UIImage *)photo{
	self.PhotoView.image = photo;
	[self showFilterView];
}

-(CIImage*)makeBoxForFace:(CIFaceFeature*)face{
	CIColor *color = [CIColor colorWithRed:0 green:0 blue:1 alpha:.33];
	CIImage *image = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", color, nil].outputImage;
	
	image = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, image, @"inputRectangle",[CIVector vectorWithCGRect:face.bounds], nil].outputImage;
	return image;
}


-(CIImage*)makeBox:(CGRect)bounds{
	CIColor *color = [CIColor colorWithRed:0 green:0 blue:1 alpha:.33];
	CIImage *image = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", color, nil].outputImage;
	
	image = [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, image, @"inputRectangle",[CIVector vectorWithCGRect:bounds], nil].outputImage;
	return image;
}


- (void)initFilterView {
    UIScrollView *scrollView = (UIScrollView*)[self.view viewWithTag:FILTER_VIEW];
	
	scrollView.contentSize = CGSizeMake(50, 468);
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"punchfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(detectFaces) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];
	
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,52, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"bullseyefilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createBullseyeFilter) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];

	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,104, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"eggfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createEggFilter) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];

	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,156, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"clownfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createClown) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];
	
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,208, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"hammerfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createHammerFilter) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];
	
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,260, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"skilletfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createStarsFilter) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];
	
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0,310, 50, 50)];
	[btn setImage:[UIImage imageNamed:@"pacifierfilter.png"] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(createPacifierFilter) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview: btn];
}

-(void)updateFaceBoxes{
	
	CIImage *coreImage = [CIImage imageWithCGImage:PhotoView.image.CGImage];
	
	coreImage = [self makeBox:CGRectMake(160, 200, 100, 100)];
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.view addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 100, 100);
		[self hideProgressView];
		[self showFilterView];
		[self showFilterButtons];

	});
}


- (IBAction)subtractFilterAction:(id)sender {
	UIImageView *filterBox = (UIImageView *)[self.view viewWithTag:ACTIVE_FILTER_VIEW];
	CGSize newSize = CGSizeMake(filterBox.frame.size.width * (1 - RESIZE_MULTIPLIER), filterBox.frame.size.height * (1 -RESIZE_MULTIPLIER));
	filterBox.frame = CGRectMake(filterBox.frame.origin.x, filterBox.frame.origin.y, newSize.width, newSize.height);
	
}

- (IBAction)addFilterAction:(id)sender {
	UIImageView *filterBox = (UIImageView *)[self.view viewWithTag:ACTIVE_FILTER_VIEW];
	CGSize newSize = CGSizeMake(filterBox.frame.size.width * (1 + RESIZE_MULTIPLIER), filterBox.frame.size.height * (1+ RESIZE_MULTIPLIER));
		filterBox.frame = CGRectMake(filterBox.frame.origin.x, filterBox.frame.origin.y, newSize.width, newSize.height);
}

- (IBAction)opacityAction:(id)sender {
	UIImageView *punch = (UIImageView*)[self.view viewWithTag:ACTIVE_FILTER_VIEW];
	punch.alpha = self.opacitySlider.value;
}

- (IBAction)resetFilter:(id)sender {
	UIView *view = [self.view viewWithTag:ACTIVE_FILTER_VIEW];
	[view removeFromSuperview];
	view.tag = 0;
	view = nil;
	
	[self showFilterView];
	[self hideFilterButtons];
}

- (IBAction)sendEmail:(id)sender {
	
	if(self.PhotoView.image == nil) return;
	
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate = self;
		[mailer setSubject:@"You got Sucka Punched!"];
		UIImage *photo = [self createImageScreenShot];
		NSData *imageData = UIImagePNGRepresentation(photo);
		[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"suckapunchphoto"];
		NSString *emailBody = @"You got Sucka Punched!";
		[mailer setMessageBody:emailBody isHTML:NO];
		[self presentViewController:mailer animated:YES completion:nil];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^(void){
			[TestFlight passCheckpoint:@"Sending Email"];
		});
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Send mail is not supported on your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^(void){
			[TestFlight passCheckpoint:@"Sending Email not supported"];
		});
		[alert show];
	}
}



- (IBAction)savePhoto:(id)sender {
	if(self.PhotoView.image != nil)
		[self saveImageToLibary];
}

- (IBAction)sendTweet:(id)sender {
	if(self.PhotoView.image == nil) return;
	
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
		SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[tweetSheet setInitialText:@"You got Sucka Punched!"];
		[tweetSheet addImage:[self createImageScreenShot]];
		[self hideFilterView];
		[self presentViewController:tweetSheet animated:YES completion:nil];
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your can't send a tweet right now. Make sure you have an account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alert show];
	}
}

- (IBAction)postToFacebook:(id)sender {
	if(self.PhotoView.image == nil) return;
	
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
		SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[facebook setInitialText:@"You got Sucka Punched!"];
		[facebook addImage:[self createImageScreenShot]];
		[self hideFilterView];
		[self presentViewController:facebook animated:YES completion:nil];
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your can't post to Facebook. Make sure you have an account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)detectFaces {
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createBlackEye];
								 });
	
}

-(void)createBullseyeFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createBullseye];
								 });
	
}

-(void)createEggFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createEgg];
								 });
	
}

-(void)createClownFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createClown];
								 });
	
}

-(void)createHammerFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createHammerLump];
								 });
	
}

-(void)createStarsFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createStars];
								 });
}

-(void)createPacifierFilter{
	[self showProgressView];
	dispatch_async(
								 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
								 ^(void){
									 [self createPacifier];
								 });
}

-(void)createHammerLump{
	
	UIImage *clown = [UIImage imageNamed:@"hammerlump.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:clown.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 100, 100);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});
	
}

-(void)createStars{
	
	UIImage *clown = [UIImage imageNamed:@"stars.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:clown.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 79, 66);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});
	
}

-(void)createPacifier{
	
	UIImage *pacifier = [UIImage imageNamed:@"pacifier.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:pacifier.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 78, 70);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});
	
}

-(void)createClown{
	
	UIImage *clown = [UIImage imageNamed:@"clown.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:clown.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 100, 100);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});
	
}


-(void)createBlackEye{
	
	UIImage *blackeye = [UIImage imageNamed:@"blackeye.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:blackeye.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 100, 100);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});

}

-(void)createBullseye{
	
	UIImage *blackeye = [UIImage imageNamed:@"bullseye.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:blackeye.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 50, 50);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
	});
	
}

-(void)createEgg{
	
	UIImage *egg = [UIImage imageNamed:@"egg.png"];
	CIImage *coreImage = [CIImage imageWithCGImage:egg.CGImage];
	
	
	CGImageRef cgImage = [self.imageContext createCGImage:coreImage fromRect:[coreImage extent]];
	
	
	dispatch_async(dispatch_get_main_queue(), ^(void){
		UIImageView *filterBox = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
		filterBox.tag = ACTIVE_FILTER_VIEW;
		[self.PhotoView addSubview: filterBox];
		filterBox.frame = CGRectMake(160, 200, 50, 50);
		[self hideProgressView];
		[self hideFilterView];
		[self showFilterButtons];
		
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	if (CGRectContainsPoint([self.view viewWithTag:ACTIVE_FILTER_VIEW].frame, touchLocation)) {
		dragging = YES;
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	
	if (dragging) {		
		CGRect frame = [self.view viewWithTag:ACTIVE_FILTER_VIEW].frame;
		frame.origin.x =  touchLocation.x + 5;
		frame.origin.y =  touchLocation.y + 5;
		[self.view viewWithTag:ACTIVE_FILTER_VIEW].frame = frame;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	dragging = NO;
}
- (void)viewDidUnload {
	[self setResetBtn:nil];
	[self setLibrary:nil];
	[super viewDidUnload];
}
@end
