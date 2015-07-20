//
//  ViewController.m
//  FaceFound
//
//  Created by gauravds on 7/20/15.
//  Copyright (c) 2015 GDS. All rights reserved.
//

#import "ViewController.h"
#import "GCIFaceDetectorHandler.h"
#import "ImagePickerViewController.h"

@import AVFoundation;

@interface ViewController () <MyImagePickerDelegate, UITableViewDataSource>{
    GCIFaceDetectorHandler *faceRecObj;
    ImagePickerViewController *imgPicker;
    
    IBOutlet UIImageView *__weak imgView1;
    NSArray *arrTblData;
    IBOutlet UITableView *__weak tblView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    faceRecObj = [GCIFaceDetectorHandler sharedReference];
    
    imgPicker = [ImagePickerViewController new];
}

- (IBAction)btnTakePic:(id)sender {
    [imgPicker getImageFromImagePicker:self];
}

- (void)imageFromMyImagePickerDelegate:(UIImage*)imageFromPicker {
    imgView1.image = imageFromPicker;
    arrTblData = [faceRecObj facesDetectFromImage:imageFromPicker
                                   withImageWrite:NO
                                     andImageName:@"New"];
    [tblView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrTblData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    [cell.imageView setImage:arrTblData[indexPath.row]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
