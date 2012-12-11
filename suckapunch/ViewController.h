//
//  ViewController.h
//  suckapunch
//
//  Created by Keith Elliott on 12/4/12.
//  Copyright (c) 2012 Keith Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *PhotoView;
@property (strong, nonatomic) CIContext *imageContext;
@property (strong, nonatomic) IBOutlet UIView *progressView;

- (void)detectFaces;
-(CIImage*)makeBoxForFace:(CIFaceFeature*)face;
-(void)updateFaceBoxes;
-(void)showPhotoLibrary;
- (IBAction)punchAction:(id)sender;
-(void)displayPhoto:(UIImage *)photo;
-(UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

@end
