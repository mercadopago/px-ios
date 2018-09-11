//
// MLUIPriceView.m
// MercadoLibre
//
// Created by Sebastián Bravo on 14/1/15.
// Copyright (c) 2015 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "MLUIPriceView.h"
#import <MLUI/UIColor+Theme.h>
#import "UIFont+MLFonts.h"
#import "MLUIBundle.h"

@interface MLUIPriceView ()

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) NSDictionary *fontSizesDictionary;
@property (nonatomic, strong) NSDictionary *defaultStyleSizesDictionary;

@end

@implementation MLUIPriceView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self createPriceView];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self createPriceView];
	}

	return self;
}

- (void)createPriceView
{
	NSArray *nibObjects = [[MLUIBundle mluiBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
	MLUIPriceView *view = nibObjects[0];
	[self addSubview:view];

	view.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *views = @{@"view" : view};

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];

	// Diccionario que guarda los distintos tamaños de fuente para el de descuento
	NSDictionary *discountStyleSizesDictionary = @{@(MLPriceSizeLarge) : @16, @(MLPriceSizeMedium) : @12, @(MLPriceSizeSmall) : @12};

	// Diccionario que guarda los distintos tamaños de fuentes para el de default
	self.defaultStyleSizesDictionary = @{@(MLPriceSizeLarge) : @32, @(MLPriceSizeMedium) : @20, @(MLPriceSizeSmall) : @16};

	// Para poderconsultar acorde a un estilo de precio y un estilo de tamaño, la fuente correspondiente
	self.fontSizesDictionary = @{@(MLPriceViewDiscountStyle) : discountStyleSizesDictionary, @(MLPriceViewDefaultStyle) : self.defaultStyleSizesDictionary, @(MLPriceViewDisabledStyle) : self.defaultStyleSizesDictionary};
}

// Obtengo la fuente correspondiente al estilo de precio y estilo de tamaño
- (void)setFontWithViewStyle:(MLPriceViewStyle)viewStyle andSizeStyle:(MLPriceSizeStyle)sizeStyle
{
	NSNumber *fontSize = self.fontSizesDictionary[@(viewStyle)][@(sizeStyle)];

	self.priceLabel.font = [UIFont ml_lightSystemFontOfSize:[fontSize floatValue]];

	_font = self.priceLabel.font;
}

- (void)layoutViewWithString:(NSString *)priceString fontSizeStyle:(MLPriceSizeStyle)sizeStyle
{
	self.priceLabel.font = [UIFont systemFontOfSize:[self.defaultStyleSizesDictionary[@(sizeStyle)] floatValue]];

	self.priceLabel.textColor = [UIColor ml_defaultPriceColor];

	self.priceLabel.text = priceString;

	_font = self.priceLabel.font;

	[self layoutIfNeeded];
}

- (void)layoutViewWithNumber:(NSNumber *)priceNumber formatter:(NSNumberFormatter *)formatter style:(MLPriceViewStyle)priceStyle fontSizeStyle:(MLPriceSizeStyle)sizeStyle
{
	// Si no me mandan precio o formatter, entonces no muestro precio y actualizo la UI
	if (!priceNumber || !formatter) {
		self.priceLabel.text = nil;

		[self layoutIfNeeded];
		return;
	}

	[self setFontWithViewStyle:priceStyle andSizeStyle:sizeStyle];

	if (priceStyle == MLPriceViewDiscountStyle) {
		[self createDiscountPriceWithNumber:priceNumber andFormatter:formatter];
	} else {
		[self createDefaultPriceWithNumber:priceNumber andFormatter:formatter style:priceStyle];
	}
}

- (NSMutableAttributedString *)attributedStringForPriceNumber:(NSNumber *)priceNumber withFormatter:(NSNumberFormatter *)formatter
{
	// Obtengo el string referente al precio que se me paso como parametro
	NSString *priceString = [NSString stringWithFormat:@"%@ %@", formatter.currencySymbol, [formatter stringFromNumber:priceNumber]];

	// Creo el attributedString del precio
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priceString];

	// Separo los decimales (en caso de que tenga) de la parte entera
	if (formatter.decimalSeparator) {
		NSRange rangeOfDecimalSeparator = [priceString rangeOfString:formatter.decimalSeparator];

		// Si existen los decimales realmente, le seteo los atributos correspondientes al estilo
		if (rangeOfDecimalSeparator.location != NSNotFound) {
			// Elimino el separador decimal
			[attributedString deleteCharactersInRange:rangeOfDecimalSeparator];

			// La tamaño de la fuente para la parte decimal es la mitad del tamaño de la original
			UIFont *decimalFont = [UIFont fontWithName:self.font.fontName size:self.font.pointSize * 0.4];
			NSNumber *offsetDecimalFont = @(self.font.capHeight - decimalFont.capHeight);

			// Agrego los atributos necesarios para que los decimales se vean mas chicos y arriba
			NSRange rangeOfDecimals = NSMakeRange(rangeOfDecimalSeparator.location, priceString.length - (rangeOfDecimalSeparator.location + 1));
			[attributedString addAttribute:NSBaselineOffsetAttributeName value:offsetDecimalFont range:rangeOfDecimals];
			[attributedString addAttribute:NSFontAttributeName value:decimalFont range:rangeOfDecimals];
		}
	}
	return attributedString;
}

// Crear label con estilo de descuento
- (void)createDiscountPriceWithNumber:(NSNumber *)priceNumber andFormatter:(NSNumberFormatter *)formatter
{
	// Seteo los atributos del string referentes a fuente y color
	self.priceLabel.textColor = [UIColor ml_discountPriceColor];

	// Obtengo los atributos base para el precio
	NSMutableAttributedString *priceString = [self attributedStringForPriceNumber:priceNumber withFormatter:formatter];

	// Aplico el atributo correspondiente al precio con descuento (tachado)
	[priceString addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, priceString.string.length)];

	self.priceLabel.attributedText = priceString;

	[self layoutIfNeeded];
}

// Crear label con estilo normal
- (void)createDefaultPriceWithNumber:(NSNumber *)priceNumber andFormatter:(NSNumberFormatter *)formatter style:(MLPriceViewStyle)style
{
	// Si el estilo es inhabilitado
	if (style == MLPriceViewDisabledStyle) {
		self.priceLabel.textColor = [UIColor ml_disabledPriceColor];
	} else {
		self.priceLabel.textColor = [UIColor ml_defaultPriceColor];
	}

	// Obtengo los atributos base para el precio
	self.priceLabel.attributedText = [self attributedStringForPriceNumber:priceNumber withFormatter:formatter];

	[self layoutIfNeeded];
}

@end
