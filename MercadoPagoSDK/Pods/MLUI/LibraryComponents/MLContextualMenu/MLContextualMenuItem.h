//
// MLContextualMenuItem.h
// MLUI
//
// Created by Nicolas Guido Brucchieri on 5/11/16.
//
//

#import <Foundation/Foundation.h>

/*!
 *  @brief Contextual menu item to show in MLContextualMenu
 */
@interface MLContextualMenuItem : NSObject

/*
** Item text
*/
@property (nonatomic, copy) NSString *text;

/*
** Item image name
*/
@property (nonatomic, copy) NSString *imageName __attribute__((deprecated("Use image property.")));

/*
** Item image
*/
@property (nonatomic, strong) UIImage *image;

/*
** Item is selected
*/
@property (nonatomic, assign) BOOL selected;

/**
 *  Init method
 *
 *  @param text Item text
 *
 *  @param image Item image to show in the menu.
 *
 *  @param selected Item is selected
 *
 *  @return MLContextualMenuItem
 */
- (instancetype)initWithText:(NSString *)text image:(UIImage *)image selected:(BOOL)selected;

/**
 *  Init method
 *
 *  @param text Item text
 *
 *  @param imageName Item image name. This image will be search in main bundle.
 *
 *  @param selected Item is selected
 *
 *  @return MLContextualMenuItem
 */
- (instancetype)initWithText:(NSString *)text imageName:(NSString *)imageName selected:(BOOL)selected __attribute__((deprecated("We recommend start using the initWithText:image:selected: instead.")));

@end
