//
//  GCIFaceDetectorHandler.h
//
//  Created by Gaurav D. Sharma on 02.12.14.
//  Copyright (c) 2014 Gaurav D. Sharma. All rights reserved.
//

#import "GCIFaceDetectorHandler.h"
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface GCIFaceDetectorHandler()

@property (nonatomic, assign) CGAffineTransform transformToUIKit;

@end

@implementation GCIFaceDetectorHandler


// thread safe singleton refernce of object
+ (instancetype)sharedReference {
    static GCIFaceDetectorHandler *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GCIFaceDetectorHandler alloc] init];
    });
    return singleton;
}

- (NSArray*)facesDetectFromImage:(UIImage*)image
                  withImageWrite:(BOOL)isWriteImage
                    andImageName:(NSString*)imageName {
    // if argument has error
    if (!image) {
        NSLog(@"%@",@"CIFaceDetectorHandler argument image error");
        return nil;
    }
    if (isWriteImage && !imageName) {
        NSLog(@"%@",@"CIFaceDetectorHandler argument image name error, you are writing image to file");
        return nil;
    }
    
    
    NSInteger imageUniqueName = 1;
	//this is the translation from the CIImage coordinates to the UIKit coordinates
	CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
	self.transformToUIKit = CGAffineTransformTranslate(transform, 0, -image.size.height);
	
	
	//a context and our image to get started!
	CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
	CIImage * coreImage = 	[[CIImage alloc] initWithImage:image];

	
	//TODO: 14 create a NSDictionary with the key CIDetectorAccuracy set to CIDetectorAccuracyHigh
	NSDictionary * detectorOptions = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
	
	
	//TODO: 15 create a CIDetector of type CIDetectorTypeFace
	CIDetector * detector =	[CIDetector detectorOfType:CIDetectorTypeFace
                                               context:context
                                               options:detectorOptions];
	
	
	//TODO: 16 get all CIFaceFeatures the detector can find in the coreImage
	NSArray * foundFaces = [detector featuresInImage:coreImage];

	NSMutableArray *arrayFaces = [NSMutableArray new];
    NSString *documentsDirectory = DOCUMENT_PATH;

    if (foundFaces.count > 0) {
        for (CIFaceFeature * feature in foundFaces) {
            @autoreleasepool {
                UIImage *imgFace = [self cropImage:coreImage withSize:feature.bounds];
                [arrayFaces addObject:imgFace];
                if (isWriteImage) {
                    NSString *imgName = [NSString stringWithFormat:@"Face%ld_%@",(long)imageUniqueName++,imageName];
                    NSString *imageCompletePath = [documentsDirectory stringByAppendingPathComponent:imgName];
                    [self writeImageToLocalPath:imgFace
                                       withName:imageCompletePath];
                }
            }
        }
        // return faces array
        return [NSArray arrayWithArray:arrayFaces];
    }
    
    return nil;
    
}
- (UIImage*)cropImage:(CIImage*)coreImage withSize:(CGRect)rect {
    CIVector *cropRect = [CIVector vectorWithCGRect:rect];
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setValue:coreImage forKey:@"inputImage"];
    [cropFilter setValue:cropRect forKey:@"inputRectangle"];
    CIImage *croppedImage = [cropFilter valueForKey:@"outputImage"];
    return [[UIImage alloc] initWithCIImage:croppedImage];
}

- (void)writeImageToLocalPath:(UIImage*)image withName:(NSString*)name {
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:name
                atomically:YES];
}

@end
