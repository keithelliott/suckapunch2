//
//  UIView+UIView_Utils.h
//  suckapunch
//
//  Created by Keith Elliott on 12/6/12.
//  Copyright (c) 2012 Keith Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_Utils)
-(BOOL)hasFourInchDisplay;
-(BOOL)isCameraAvailable;
-(BOOL)isFrontCameraAvailable;
-(BOOL)isBackCameraAvailable;
-(BOOL)isFlashAvailableOnFrontCamera;
-(BOOL)isFlashAvailableOnRearCamera;
-(BOOL)doesCameraSupportShootingVideos;
-(BOOL)doesCameraSupportTakingPhotos;
-(BOOL)cameraSupportsMedia:(NSString*)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;
@end
