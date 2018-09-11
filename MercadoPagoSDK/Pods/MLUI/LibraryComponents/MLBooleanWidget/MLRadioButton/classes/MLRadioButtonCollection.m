//
// MLRadioButtonCollection.m
// MLUI
//
// Created by Santiago Lazzari on 6/9/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLRadioButtonCollection.h"

#import "MLRadioButton.h"
#import "MLBooleanWidget.h"

@interface MLRadioButtonCollection () <MLBooleanWidgetDelegate>

@property (strong, nonatomic) NSMutableArray *radioButtonsMutableArray;
@property (strong, nonatomic) MLRadioButton *selectedRadioButton;

@end

@implementation MLRadioButtonCollection

#pragma mark - Init
- (instancetype)init
{
	self = [super init];

	if (self) {
		[self commonInit];
	}

	return self;
}

- (void)commonInit
{
	self.radioButtonsMutableArray = [[NSMutableArray alloc] init];
}

+ (instancetype)radioButtonCollectionWithRadioButtonCount:(NSUInteger)radioButtonCount
{
	NSAssert(radioButtonCount > 0, @"Radio button collection must have at least one radio button");
	MLRadioButtonCollection *radioButtonCollection = [[self alloc] init];

	for (NSUInteger index = 0; index < radioButtonCount; ++index) {
		MLRadioButton *radioButton = [MLRadioButton booleanWidgetWithDelegate:radioButtonCollection];

		[radioButtonCollection.radioButtonsMutableArray addObject:radioButton];
	}

	radioButtonCollection.selectedRadioButton = radioButtonCollection.radioButtonsMutableArray.firstObject;

	return radioButtonCollection;
}

+ (instancetype)radioButtonCollectionWithRadioButtons:(NSArray *)radioButtons
{
	NSAssert(radioButtons.count > 0, @"Radio button collection must have at least one radio button");
	MLRadioButtonCollection *radioButtonCollection = [[self alloc] init];

	radioButtonCollection.radioButtonsMutableArray = [NSMutableArray arrayWithArray:radioButtons];

	for (MLRadioButton *radioButton in radioButtonCollection.radioButtonsMutableArray) {
		radioButton.delegate = radioButtonCollection;
	}

	[radioButtonCollection selectRadioButtonAtIndex:0];

	return radioButtonCollection;
}

#pragma mark - Getters
- (NSArray *)radioButtons
{
	return self.radioButtonsMutableArray;
}

#pragma mark - Selection
- (void)selectRadioButtonAtIndex:(NSUInteger)index
{
	MLRadioButton *selectedRadioButton = self.radioButtonsMutableArray[index];

	if (selectedRadioButton == self.selectedRadioButton) {
		return;
	}

	[self.selectedRadioButton off];

	[selectedRadioButton on];
	self.selectedRadioButton = selectedRadioButton;
}

- (NSUInteger)indexOfSelectedRadioButton
{
	return [self.radioButtonsMutableArray indexOfObject:self.selectedRadioButton];
}

#pragma mark - MLSelectionWidgetDelegate
- (void)booleanWidgetDidRequestChangeOfState:(MLBooleanWidget *)booleanWidget
{
	if ([booleanWidget isOff]) {
		[self selectRadioButtonAtIndex:[self.radioButtonsMutableArray indexOfObject:booleanWidget]];
	}
}

@end
