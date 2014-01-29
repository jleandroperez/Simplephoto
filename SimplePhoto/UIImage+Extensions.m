//
//  UIImage+Extensions.m
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "UIImage+Extensions.h"



@implementation UIImage (Extensions)

- (UIImage*)scaleToSize:(CGSize)newSize
{
    CGImageRef imageRef = [self CGImage];
	
    if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight)
    {
        CGFloat width = newSize.width;
        newSize.width = newSize.height;
        newSize.height = width;
    }
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmap = CGBitmapContextCreate(nil,
                                                newSize.width,
                                                newSize.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * newSize.width,
                                                rgbColorspace,
                                                kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
	// Fix. Ref: http://stackoverflow.com/questions/8794218/iphone-sdk-error-cgbitmapcontextcreate-unsupported-color-space
	//                                                CGImageGetColorSpace(imageRef),
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationNone);
    
    // Draw into the context, this scales the image
    CGRect imageRect = CGRectMake(0.0f, 0.0f, newSize.width, newSize.height);
    CGContextDrawImage(bitmap, imageRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref scale:self.scale orientation:self.imageOrientation];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    CGColorSpaceRelease(rgbColorspace);
	
    return result;
}

@end
