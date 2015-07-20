//
//  ImagePickerViewController.m
//  PassportApp
//
//  Created by Balaji on 26/09/14.
//  Copyright (c) 2014 ___baltech___. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface UIImage (ImageCrop)

- (UIImage *)scaledToSize:(CGSize)newSize;

- (UIImage *)fixOrientation;

@end

@implementation UIImage (ImageCrop)

- (UIImage *)scaledToSize:(CGSize)newSize
{
    //    pr(@"%f",[UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end


@interface ImagePickerViewController () <UIAlertViewDelegate>
{
    UIAlertView *alert;
    UIImage *image;
    
    UIImagePickerController *imgPicker;
    UIPopoverController  *popoverVC;
}
@end


@implementation ImagePickerViewController

@synthesize delegate;
@synthesize imageHeight, imageWidth;


- (void)getImageFromImagePicker:(UIViewController<MyImagePickerDelegate>*)delegateM {
    if (delegate == nil) {
        delegate = delegateM;
    }
    
    if (imageHeight == 0.0f || imageWidth == 0.0f) {
        imageWidth = 500.0f;
        imageHeight = 500.0f;
    }

    
    alert = [[UIAlertView alloc] initWithTitle:@""
                                       message:@"Please choose option to take photo"
                                      delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"Camera",@"Photo gallery", nil];
    [alert show];
    
}
#pragma mark - UIAlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // for image take : camera or photo gallery
    imgPicker = [UIImagePickerController new];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate = self;
    imgPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    imgPicker.popoverPresentationController.sourceView = delegate.view;
    imgPicker.popoverPresentationController.sourceRect = delegate.view.frame;
    
    if (buttonIndex == 1) { // camera
#if !(TARGET_IPHONE_SIMULATOR)
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
#else
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif

    } else if (buttonIndex == 2) { // photo gallery
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        return;
    }
    
    [delegate presentViewController:imgPicker animated:YES completion:nil];
}
#pragma mark - image picker delegates
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // get edited image
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // make new size image (small size)
    image = [image scaledToSize:CGSizeMake(imageWidth, imageHeight)];
    
    image = [image fixOrientation];
    
    [delegate imageFromMyImagePickerDelegate:image];
    
	[picker dismissViewControllerAnimated:NO completion:nil];
}




@end
