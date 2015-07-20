//
//  ImagePickerViewController.h
//  PassportApp
//
//  Created by Balaji on 26/09/14.
//  Copyright (c) 2014 ___baltech___. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MyImagePickerDelegate<NSObject>
@required
- (void)imageFromMyImagePickerDelegate:(UIImage*)imageFromPicker;
@end




@interface ImagePickerViewController : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    
}
@property (nonatomic, strong) UIViewController<MyImagePickerDelegate> *delegate;

@property (nonatomic) CGFloat imageHeight, imageWidth;

- (void)getImageFromImagePicker:(UIViewController<MyImagePickerDelegate>*)delegateM;
@end



