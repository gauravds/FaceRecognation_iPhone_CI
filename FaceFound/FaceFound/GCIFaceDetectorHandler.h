//
//  GCIFaceDetectorHandler.h
//
//  Created by Gaurav D. Sharma on 02.12.14.
//  Copyright (c) 2014 Gaurav D. Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCIFaceDetectorHandler : NSObject
+ (instancetype)sharedReference;

- (NSArray*)facesDetectFromImage:(UIImage*)image
                  withImageWrite:(BOOL)isWriteImage
                    andImageName:(NSString*)imageName;
@end
