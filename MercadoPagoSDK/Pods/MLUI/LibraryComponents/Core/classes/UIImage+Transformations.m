//
// UIImage+MercadoLibre.m
// MercadoLibre
//
// Created by Sebastián Bravo on 07/06/13.
// Copyright (c) 2013 Casa. All rights reserved.
//

#import "UIImage+Transformations.h"

@implementation UIImage (MercadoLibre)

+ (UIImage *)ml_autoAdjustImageToScale:(UIImage *)anImage
{
	CGFloat screenScale = [UIScreen mainScreen].scale;
	UIImage *finalImage;
	if (screenScale != anImage.scale) {
		finalImage = [UIImage imageWithCGImage:anImage.CGImage scale:screenScale orientation:anImage.imageOrientation];
	} else {
		finalImage = anImage;
	}

	return finalImage;
}

- (UIImage *)ml_imageWithRoundedCorners:(UIRectCorner)corners cornerRadius:(CGSize)cornerRadius
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);

	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.size.width, self.size.height)

	                                               byRoundingCorners:corners

	                                                     cornerRadii:cornerRadius];

	[maskPath addClip];

	[self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];

	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}

- (UIImage *)ml_imageByScalingToSize:(CGSize)targetSize
{
	UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
	[self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

- (UIImage *)ml_imageByScalingToFitSize:(CGSize)targetSize
{
	CGFloat aspect = self.size.width / self.size.height;
	CGSize sizeToScale;
	if (targetSize.width / aspect <= targetSize.height) {
		sizeToScale = CGSizeMake(targetSize.width, targetSize.width / aspect);
	} else {
		sizeToScale = CGSizeMake(targetSize.height * aspect, targetSize.height);
	}

	return [self ml_imageByScalingToSize:sizeToScale];
}

- (UIImage *)ml_cropImageToRect:(CGRect)rect
{
	CGFloat scale = self.scale;
	CGRect scaledRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], scaledRect);
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:self.imageOrientation];
	CGImageRelease(imageRef);
	return croppedImage;
}

@end
