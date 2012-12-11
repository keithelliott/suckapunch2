//
//  UIView+UIView_Utils.m
//  suckapunch
//
//  Created by Keith Elliott on 12/6/12.
//  Copyright (c) 2012 Keith Elliott. All rights reserved.
//

#import "UIView+UIView_Utils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIView (UIView_Utils)
-(BOOL)hasFourInchDisplay{
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

-(BOOL)isCameraAvailable{
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

-(BOOL)isFrontCameraAvailable{
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceFront];
}

-(BOOL)isBackCameraAvailable{
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceRear];
}

-(BOOL)isFlashAvailableOnFrontCamera{
	return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront];
}

-(BOOL)isFlashAvailableOnRearCamera{
	return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}

-(BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
	__block BOOL result = NO;
	
	if([paramMediaType length] == 0){
		return NO;
	}
	
	NSArray *availMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
	
	[availMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		NSString *mediaType = (NSString *)obj;
		if([mediaType isEqualToString:paramMediaType]){
			result = YES;
			*stop = YES;
		}
	}];
	
	return result;
}

-(BOOL)doesCameraSupportShootingVideos{
	return [self cameraSupportsMedia:(__bridge NSString*)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

-(BOOL)doesCameraSupportTakingPhotos{
	return [self cameraSupportsMedia:(__bridge NSString*)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}
@end
