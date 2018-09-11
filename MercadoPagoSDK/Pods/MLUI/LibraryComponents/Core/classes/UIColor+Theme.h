//
// UIColor+MercadoLibre.h
// MercadoLibre
//
// Created by Fabian Celdeiro on 8/22/12.
// Copyright (c) 2012 Casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)

/**
 *  Retorna una instancia de UIColor con el color por default para el texto de feedback
 *  en las acciones del detalle de un item
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_textFeedbackColor;

/**
 *  Retorna una instancia de UIColor con el color por default para el texto
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_textDefaultColor;

/**
 *  Retorna una instancia de UIColor con el color por default para el texto de un subtitulo
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_textSubtitleColor;

/**
 *  Retorna una instancia de UIColor con el color por default para el fondo de una celda
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_cellBackgroundDefaultColor;

/**
 *  Retorna una instancia de UIColor con el color por default para el fondo de una celda
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_backgroundDefaultColor;

/**
 *  Retorna una instancia de UIColor con el color por default para el fondo de un TableView
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_tableViewBackgroundDefaultColor;

/**
 *  Retorna una instancia de UIColor con el color de fondo para mostrar errores
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_bigErrorBackgroundDefaultColor;

/**
 *  Retorna una instancia de UIColor con el color para el precio
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_priceColor;

/**
 *  Retorna una instancia de UIColor con el color azul mas brillante
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_mercadoLibreLightBlueColor;

/**
 *  Retorna una instancia de UIColor con el color azul
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_mercadoLibreBlueColor;

/**
 *  Retorna una instancia de UIColor con el color que tendra la celda que muestra un error
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_errorCellColor;

/**
 *  Retorna una instancia de UIColor con el color que tendra la celda que muestra un warning
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_warningCellColor;

/**
 *  Retorna una instancia de UIColor con el color de fondo que se muestra para mis MisCompras
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_tableViewMisComprasBackgroundColor;

/**
 *  Retorna una instancia de UIColor con el color de fondo que se muestra como footer
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_tableViewMisComprasFooterBackgroundColor;

/**
 *  Retorna una instancia de UIColor con el color de fondo para el navigation bar
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_navigationBarColor;

/**
 *  Retorna una instancia de UIColor con el color del texto del navigation bar
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_textNavigationBarColor;

/**
 *  Retorna una instancia de UIColor con el color de fondo para el tableView en iOS7
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_iOS7TableViewBackgroundColor;

/**
 *  Retorna una instancia de UIColor con el color del tabbar
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_tabBarColor;

/**
 *  Retorna una instancia de UIColor con el color de listingsDetailLine
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_listingsDetailLine;

/**
 *  Retorna una instancia de UIColor con el color del titulo
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_titleColor;

/**
 *  Modifica una instaancia de UIColor haciendola mas brillante
 *
 *  @return Instancia de UIColor
 */
- (UIColor *)ml_lighterColor;

/**
 *  Modifica una instaancia de UIColor haciendola mas oscura
 *
 *  @return Instancia de UIColor
 */
- (UIColor *)ml_darkerColor;

/**
 *  Retorna una instancia de UIColor con el color default del texto del precio
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_defaultPriceColor;

/**
 *  Retorna una instancia de UIColor con el color inhabilitado del texto del precio
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_disabledPriceColor;

/**
 *  Retorna una instancia de UIColor con el color default del texto del precio con descuento
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)ml_discountPriceColor;

@end
