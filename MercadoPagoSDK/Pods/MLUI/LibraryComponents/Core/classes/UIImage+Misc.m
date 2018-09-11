//
// UIImage+Misc.m
// MLUI
//
// Created by Leandro Fantin on 19/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "UIImage+Misc.h"

@implementation UIImage (Misc)

+ (UIImage *)ml_imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);

	UIImage *image = [UIImage ml_imageWithColor:color frame:rect];

	return image;
}

+ (UIImage *)ml_imageWithColor:(UIColor *)color frame:(CGRect)rect
{
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (BOOL)ml_isEqualToImage:(UIImage *)anotherImage
{
	NSData *imgdata1 = UIImagePNGRepresentation(self);
	NSData *imgdata2 = UIImagePNGRepresentation(anotherImage);

	return [imgdata1 isEqualToData:imgdata2];
}

+ (UIImage *)ml_takeScreenSnapshotFromView:(UIView *)viewToSnapshot
{
	UIGraphicsBeginImageContext(viewToSnapshot.bounds.size);
	if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
		[viewToSnapshot drawViewHierarchyInRect:
		 viewToSnapshot.bounds afterScreenUpdates:NO];
	} else {
		[viewToSnapshot.layer renderInContext:
		 UIGraphicsGetCurrentContext()];
	}

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
	image = [UIImage imageWithData:imageData];

	return image;
}

- (UIImage *)ml_tintedImageWithColor:(UIColor *)tintColor
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextDrawImage(context, rect, self.CGImage);

	CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	[tintColor setFill];
	CGContextFillRect(context, rect);

	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return coloredImage;
}

@end
