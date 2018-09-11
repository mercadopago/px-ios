//
// MLContextualMenuItem.m
// MLUI
//
// Created by Nicolas Guido Brucchieri on 5/11/16.
//
//

#import "MLContextualMenuItem.h"

@implementation MLContextualMenuItem

- (instancetype)initWithText:(NSString *)text imageName:(NSString *)imageName selected:(BOOL)selected
{
	self = [super init];
	if (self) {
		self.text = text;
		self.imageName = imageName;
		self.image = [UIImage imageNamed:imageName]; // Try to load image in main bundle
		self.selected = selected;
	}
	return self;
}

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image selected:(BOOL)selected
{
	self = [super init];
	if (self) {
		self.text = text;
		self.image = image;
		self.selected = selected;
	}
	return self;
}

@end
