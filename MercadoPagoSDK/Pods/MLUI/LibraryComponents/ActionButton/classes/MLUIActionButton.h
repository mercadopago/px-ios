//
// MLActionButton.h
// MercadoLibre
//
// Created by Matias Ginart on 18/09/12.
// Copyright (c) 2012 Casa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MLUIActionButtonStyle {
	MLUIActionButtonStylePrimary = 0,
	MLUIActionButtonStyleSecondary,
	MLUIActionButtonStyleTertiary,
	MLUIActionButtonStyleOnlyText,
	MLUIActionButtonStyleDisabled
}  MLUIActionButtonStyle;

@interface MLUIActionButton : UIButton
/**

 *  Every MLUIActionButton created using a xib file will have the default height kDefaultHeigth (@see awakeFromNib:),the same happens if the component is initialized by code by initWithFixHeigthConstraintAndStyle:.

 */
@property (nonatomic) MLUIActionButtonStyle buttonStyle;
@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

- (id)initWithFrame:(CGRect)frame andStyle:(MLUIActionButtonStyle)buttonStyle;

- (id)initWithStyle:(MLUIActionButtonStyle)buttonStyle;

- (id)initWithFixHeigthConstraintAndStyle:(MLUIActionButtonStyle)style;

- (void)setupForStyle:(MLUIActionButtonStyle)buttonStyle;

- (void)activeSimulatedDisabled;

@end
