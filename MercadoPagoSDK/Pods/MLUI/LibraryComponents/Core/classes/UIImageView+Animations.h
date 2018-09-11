//
// UIImageView+Animations.h
// MLUI
//
// Created by Leandro Fantin on 10/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Categoria que permite realizar animaciones sobre UIImageView
 */
@interface UIImageView (Animations)

/**
 *  Realiza fadeIn con una imagen sobre un image view, el efecto tarda el valor del intervalo.
 *
 *  @param image    imagen que se utilizara para el efecto.
 *  @param interval intervalo de tiempo que durara el efecto.
 *  @param completionBlock bloque que se ejecuta al terminar la animación.
 */
- (void)ml_fadeInWithImage:(UIImage *)image andDuration:(NSTimeInterval)interval completionBlock:(void (^)(BOOL finished))completionBlock;

/**
 *  Realiza fadeOut con una imagen sobre un image view, el efecto tarda el valor del intervalo.
 *
 *  @param image    imagen que se utilizara para el efecto.
 *  @param interval intervalo de tiempo que durara el efecto.
 *  @param completionBlock bloque que se ejecuta al terminar la animación.
 */
- (void)ml_fadeOutWithImage:(UIImage *)image andDuration:(NSTimeInterval)interval completionBlock:(void (^)(BOOL finished))completionBlock;
@end
