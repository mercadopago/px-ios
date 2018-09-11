//
// MLGrowingTextViewHandler.h
// MLGrowingTextViewHandler-objc
//
// Created by hsusmita on 13/03/15.
// Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
   An NSObject subclass to handle resizing of UITextView as the user types in. The textview resizes as long as the number of lines lies between specified minimum and maximum number of lines. This class calculates total size of UITextView text and adjusts the height constraint of that UITextView. You need to provide height constraint to UITextView.
 */

@interface MLGrowingTextViewHandler : NSObject

/**
 * External TextView that will be used to make the text growing.
 */
@property (nonatomic, strong) UITextView *_Nullable textView;

/**
 * In case the animations are requested, the duration duration can be adjusted with this property (default = 0.5)
 */
@property (nonatomic, assign) CGFloat animationDuration;

/** Returns an instance of MLGrowingTextViewHandler
   @param textView The UITextView which needs to be resized
   @param heightConstraint The height constraint of textview
 */
- (id _Nonnull)initWithTextView:(UITextView *_Nullable)textView heightConstraint:(NSLayoutConstraint *_Nullable)heightConstraint;

/** Limits resizing of UITextView between minimumNumberOfLines and maximumNumberOfLines
   @param minimumNumberOfLines Lower limit on number of lines
   @param maximumNumberOfLines Upper limit on number of lines
 */
- (void)updateMinimumNumberOfLines:(NSInteger)minimumNumberOfLines andMaximumNumberOfLine:(NSInteger)maximumNumberOfLines;

/** Resizes the textView according to the amount of text.
   @param animated Specify YES if you want to animate the size change of UITextView or NO if you don't
 */

- (void)resizeTextViewAnimated:(BOOL)animated;

/** Sets text of textView and resizes it according to the length of the text
   @param animated Specify YES if you want to animate the size change of UITextView or NO if you don't
 */
- (void)setText:(NSString *_Nullable)text animated:(BOOL)animated;

@end
