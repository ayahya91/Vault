//
//  OpenCVWrapper.m
//  Vault
//
//  Created by Ahmed Yahya on 9/18/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

@implementation OpenCVWrapper

cv::FaceRecognizer *LBPHRecognizer;

- (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

- (FaceRecognizer *)createFaceRecognizer {
    LBPHRecognizer = createLBPHFaceRecognizer();
    return LBPHRecognizer;
}

- (FaceRecognizer *)faceRecognizerWithFile:(NSString *)path {
    LBPHRecognizer = createLBPHFaceRecognizer();
    LBPHRecognizer->load(path.UTF8String);
    return LBPHRecognizer;
}

- (Boolean)predict:(UIImage*)img confidence:(double *)confidence userLabels:(NSArray<NSString *>*)labelsArray {
    cv::Mat src = [self cvMatGrayFromUIImage:img];            //[img cvMatRepresentationGray];
    int label;
    LBPHRecognizer->predict(src, label, *confidence);
    NSString *labelString = [NSString stringWithFormat:@"%d",label];
    NSInteger labelIntFound = [labelsArray indexOfObject:labelString];
    if (labelIntFound == NSNotFound) {
        return false;
    } else {
        return true;
    }
}

- (void)updateWithFace:(UIImage *)img name:(NSString *)name userLabels:(NSArray<NSString *>*)labelsArray {
    cv::Mat src = [self cvMatGrayFromUIImage:img];
    NSInteger label = [labelsArray indexOfObject:name];
    if (label == NSNotFound) {
        //[labelsArray addObject:name];
        //label = [labelsArray indexOfObject:name];
        return;
    }
    vector<cv::Mat> images = vector<cv::Mat>();
    images.push_back(src);
    vector<int> labels = vector<int>();
    labels.push_back((int)label);
    LBPHRecognizer->update(images, labels);
 }

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

@end
