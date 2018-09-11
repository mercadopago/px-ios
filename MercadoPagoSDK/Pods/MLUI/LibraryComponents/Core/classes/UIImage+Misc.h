//
// UIImage+Misc.h
// MercadoLibre
//
// Created by Leandro Fantin on 19/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Misc)

/**
 *  Crea una imagen con un color solido de 1x1
 *
 *  @param color color solido
 *
 *  @return Imagen creada con un color solido
 */
+ (UIImage *)ml_imageWithColor:(UIColor *)color;

/**
 *  Crea una imagen con un color solido usando el frame pasado como parámetro
 *
 *  @param color color solido
 *
 *  @param rect CGRect que frame voy a usar para crear la imagen
 *
 *  @return Imagen creada con un color solido
 */
+ (UIImage *)ml_imageWithColor:(UIColor *)color frame:(CGRect)rect;

/**
 *  Equals que compara pixel por pixels, imagenes que pueden estar en diferente formato.
 *
 *  @param anotherImage la instancia de UIImage a comparar
 *
 *  @return true en caso de ser iguales
 */
- (BOOL)ml_isEqualToImage:(UIImage *)anotherImage;

/**
 * Crea una imagen a partir de una UIView
 * @param viewToSnapshot la instancia de UIView sobre la que se obtendrá una UIImage
 */
+ (UIImage *)ml_takeScreenSnapshotFromView:(UIView *)viewToSnapshot;

/**
 * Retorna una nueva de instancia de UIImage pintado con el tintColor
 * @param tintColor color a utilizar para pintar la imagen
 * @return nueva instancia de UIImage
 */
- (UIImage *)ml_tintedImageWithColor:(UIColor *)tintColor;

@end
