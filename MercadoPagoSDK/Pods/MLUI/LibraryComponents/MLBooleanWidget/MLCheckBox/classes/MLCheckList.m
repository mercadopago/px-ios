//
// MLCheckList.m
// MLUI
//
// Created by Santiago Lazzari on 6/15/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLCheckList.h"

#import "MLCheckBox.h"
#import "MLBooleanWidget.h"

@interface MLCheckList () <MLBooleanWidgetDelegate>

@property (strong, nonatomic) NSMutableArray *checkButtonMutableArray;
@property (strong, nonatomic) NSMutableArray *selectedCheckButtons;

@end

@implementation MLCheckList

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
	self.checkButtonMutableArray = [[NSMutableArray alloc] init];
	self.selectedCheckButtons = [[NSMutableArray alloc] init];
}

+ (instancetype)checkListWithCheckBoxCout:(NSUInteger)checkBoxCount
{
	NSAssert(checkBoxCount > 0, @"Check list must have at least one check button");
	MLCheckList *checkList = [[self alloc] init];

	for (NSUInteger index = 0; index < checkBoxCount; ++index) {
		MLCheckBox *checkButton = [MLCheckBox booleanWidgetWithDelegate:checkList];

		[checkList.checkButtonMutableArray addObject:checkButton];
	}

	return checkList;
}

+ (instancetype)checkListWithCheckBoxes:(NSArray *)checkBoxes
{
	NSAssert(checkBoxes.count > 0, @"Check list must have at least one check button");
	MLCheckList *checkList = [[self alloc] init];

	checkList.checkButtonMutableArray = [NSMutableArray arrayWithArray:checkBoxes];

	for (MLCheckBox *checkButton in checkList.checkButtonMutableArray) {
		checkButton.delegate = checkList;
	}

	return checkList;
}

- (NSArray *)checkBoxes
{
	return self.checkButtonMutableArray;
}

- (void)toggleCheckBoxAtIndex:(NSUInteger)index
{
	MLCheckBox *selectedCheckBox = [self.checkButtonMutableArray objectAtIndex:index];

	[selectedCheckBox toggle];

	if ([selectedCheckBox isOn]) {
		[self.selectedCheckButtons addObject:selectedCheckBox];
	} else {
		[self.selectedCheckButtons removeObject:selectedCheckBox];
	}
}

- (NSArray *)indexesOfSelectedCheckBoxes
{
	NSMutableArray *selectedIndexes = [[NSMutableArray alloc] init];

	for (MLCheckBox *selectedCheckButton in self.selectedCheckButtons) {
		[selectedIndexes addObject:@([self.checkButtonMutableArray indexOfObject:selectedCheckButton])];
	}

	return selectedIndexes;
}

#pragma mark - MLSelectionWidgetDelegate
- (void)booleanWidgetDidRequestChangeOfState:(MLBooleanWidget *)booleanWidget
{
	[self toggleCheckBoxAtIndex:[self.checkButtonMutableArray indexOfObject:booleanWidget]];
}

@end
