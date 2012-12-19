//
//  ViewController.h
//  suckapunch
//
//  Created by Keith Elliott on 12/4/12.
//  Copyright (c) 2012 Keith Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *resetBtn;
@property (strong, nonatomic) IBOutlet UIButton *minus;
@property (strong, nonatomic) IBOutlet UIButton *plus;
@property (strong, nonatomic) IBOutlet UIButton *punchBtn;
@property (strong, nonatomic) IBOutlet UIButton *email;
@property (strong, nonatomic) IBOutlet UIButton *twitter;
@property (strong, nonatomic) IBOutlet UIButton *facebook;
@property (strong, nonatomic) IBOutlet UIImageView *tabbar;
@property (strong, nonatomic) IBOutlet UIImageView *PhotoView;
@property (strong, nonatomic) IBOutlet UIButton *library;
@property (strong, nonatomic) IBOutlet UISlider *opacitySlider;
@property (strong, nonatomic) CIContext *imageContext;
@property (strong, nonatomic) IBOutlet UIView *progressView;
- (IBAction)subtractFilterAction:(id)sender;
- (IBAction)addFilterAction:(id)sender;
- (IBAction)opacityAction:(id)sender;
- (IBAction)resetFilter:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)savePhoto:(id)sender;
- (IBAction)sendTweet:(id)sender;
- (IBAction)postToFacebook:(id)sender;


- (void)detectFaces;
-(CIImage*)makeBoxForFace:(CIFaceFeature*)face;
-(void)updateFaceBoxes;
-(void)showPhotoLibrary;
- (IBAction)punchAction:(id)sender;
-(void)displayPhoto:(UIImage *)photo;
-(UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

@end
