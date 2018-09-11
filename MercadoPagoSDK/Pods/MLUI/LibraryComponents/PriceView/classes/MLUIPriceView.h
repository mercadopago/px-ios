//
// MLUIPriceView.h
// MercadoLibre
//
// Created by Sebastián Bravo on 14/1/15.
// Copyright (c) 2015 MercadoLibre - Mobile Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
   Para definir el tipo de precio que me interesa.
 */
typedef NS_ENUM (NSInteger, MLPriceViewStyle) {
	/**
	 *  Es el estilo que se aplica al precio con descuento
	 */
	MLPriceViewDiscountStyle,
	/**
	 *  Es el estilo que se aplica al precio normal
	 */
	MLPriceViewDefaultStyle,

	/**
	 *  Es el estilo que se aplica al precio deshabilitado
	 */
	MLPriceViewDisabledStyle
};

/**
 *  Para definir el tamaño del label. Varía acorde al estilo aplicado
 */
typedef NS_ENUM (NSInteger, MLPriceSizeStyle) {
	/**
	 *  Tamaño de texto grande
	 */
	MLPriceSizeLarge,
	/**
	 *  Tamaño de texto mediano
	 */
	MLPriceSizeMedium,
	/**
	 *  Tamaño de texto chico
	 */
	MLPriceSizeSmall
};

@interface MLUIPriceView : UIView

/**
 *  Fuente solo de modo lectura, utilizada para saber cual es la fuente que esta utilizando el componente y usarla en otro label.
 */
@property (nonatomic, readonly, strong) UIFont *font;

/**
 *  Se setea el texto al price, utilizando el estilo default de precio. Usar para 'Payment to agree'.
 *
 *  @param priceString Es el parámetro que se usa para setear como precio.
 *  @param sizeStyle Es el parámetro que se usa para indicar el tamaño que deseo que tenga el componente
 */
- (void)layoutViewWithString:(NSString *)priceString fontSizeStyle:(MLPriceSizeStyle)sizeStyle;

/**
 *  Se usa para setear un precio específico. El formatter debe ser el que se desea que se aplique al price, incluyendo la moneda, separador de decimales y de miles.
 *
 *  @param priceNumber Es el precio que deseo setear. Debe ser solo el número, sin símbolo de moneda (por ejemplo 1200.50)
 *  @param formatter   Es el NumberFormatter con el cual se le va a dar formato al number que se pasa como primer parámetro. Debe tener separador de decimales (en caso de que el país tenga), cantidad de digitos decimales, símbolo de moneda, etc.
 *  @param priceStyle  Es el estilo que deseo que tenga el precio.
 *  @param sizeStyle Es el parámetro que se usa para indicar el tamaño que deseo que tenga el componente
 */
- (void)layoutViewWithNumber:(NSNumber *)priceNumber formatter:(NSNumberFormatter *)formatter style:(MLPriceViewStyle)priceStyle fontSizeStyle:(MLPriceSizeStyle)sizeStyle;
@end
