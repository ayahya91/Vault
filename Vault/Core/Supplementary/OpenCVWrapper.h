//
//  OpenCVWrapper.h
//  Vault
//
//  Created by Ahmed Yahya on 9/18/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>


@interface OpenCVWrapper : NSObject

- (NSString *)openCVVersionString;
- (cv::FaceRecognizer *)createFaceRecognizer;
- (cv::FaceRecognizer *)faceRecognizerWithFile:(NSString *)path;
- (Boolean)predict:(UIImage*)img confidence:(double *)confidence userLabels:(NSArray<NSString *>*)labelsArray;
- (void)updateWithFace:(UIImage *)img name:(NSString *)name userLabels:(NSArray<NSString *>*)labelsArray;
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
@end
