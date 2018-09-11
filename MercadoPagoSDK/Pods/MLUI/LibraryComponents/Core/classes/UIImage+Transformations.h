//
// UIImage+Transformations.h
// MercadoLibre
//
// Created by Leandro Fantin on 19/1/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Transformations)

/**
 *  Escala una imagen utilizando el factor de escala de la pantalla del dispositivo.
 *  En caso de que la pantalla tenga el mismo factor de scala que la imagen, devuelve
 *  la misma imagen.
 *
 *  @param anImage imagen a escalar
 *
 *  @return retorna una nueva instancia de UIImage escalada
 */
+ (UIImage *)ml_autoAdjustImageToScale:(UIImage *)anImage;

/**
 *  Escala una imagen al tamaño de la pantalla del dispositivo
 *
 *  @param targetSize Tamaño al que se quiere escalar la imagen
 *
 *  @return retorna una nueva instancia de UIImage escalada
 */
- (UIImage *)ml_imageByScalingToSize:(CGSize)targetSize;

/**
 *  Le setea a la imagen un corner radius pasado como parámetro, en los corners especificados
 *
 *  @param corners      Corners que deseo que tengan el corner radius
 *  @param cornerRadius Corner radius que deseo que tengan los corners pasados como parametro. Si se le pasa (0,0), los corners serán cuadrados
 *
 *  @return retorna una nueva instancia de UIImage con los corners modificados
 */
- (UIImage *)ml_imageWithRoundedCorners:(UIRectCorner)corners cornerRadius:(CGSize)cornerRadius;

/**
 *  Escala una imagen manteniendo la relación de aspecto
 *
 *  @param targetSize Tamaño al que se quiere escalar la imagen
 *
 *  @return retorna una nueva instancia de UIImage escalada
 */
- (UIImage *)ml_imageByScalingToFitSize:(CGSize)targetSize;

/**
 *  Hace crop de la imagen al rect pasado como parametros
 *
 *  @param rect rectangulo al que se quiere cropear la imagen
 *
 *  @return retonar una nueva instancia de UIImage cropeada
 */
- (UIImage *)ml_cropImageToRect:(CGRect)rect;

@end
