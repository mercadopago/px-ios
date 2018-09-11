//
// MLContextualMenu.h
// MLUI
//
// Created by Nicolas Guido Brucchieri on 5/11/16.
//

#import <UIKit/UIKit.h>
#import "MLContextualMenuItem.h"

@protocol MLContextualMenuDataSource;
@protocol MLContextualMenuDelegate;

/*!
 *  @brief Contextual menu with action items to show when longpress detected
 */
@interface MLContextualMenu : UIView

/*
** @brief MLContextualMenu dataSource
*/
@property (nonatomic, weak) id <MLContextualMenuDataSource> dataSource;

/*
** @brief MLContextualMenu delegate
*/
@property (nonatomic, weak) id <MLContextualMenuDelegate> delegate;

/**
 *  @brief Get gesturerecognizer configured (to keep in memory you need to addGestureRecognizer to a ViewController)
 *
 *  @param delegate for gesturerecognizer
 *
 *  @return gesturerecognizer
 */
- (UILongPressGestureRecognizer *)gestureRecognizerWithDelegate:(id <UIGestureRecognizerDelegate>)delegate;

@end

/*!
 *  @brief Datasource for Contextual menu
 */
@protocol MLContextualMenuDataSource <NSObject>

@required
/**
 *  @brief Get items at point
 *
 *  @param contextualMenu the contextual menu
 *
 *  @param point where user tap
 *
 *  @return array of items
 */
- (NSArray <MLContextualMenuItem *> *)contextualMenu:(MLContextualMenu *)contextualMenu itemsAtPoint:(CGPoint)point;

@optional
/**
 *  @brief Return if have show menu (Default is YES)
 *
 *  @param contextualMenu the contextual menu
 *
 *  @param point where user tap
 *
 *  @return boolean if have to show menu
 */
- (BOOL)contextualMenu:(MLContextualMenu *)contextualMenu shouldShowMenuAtPoint:(CGPoint)point;

@end

/*!
 *  @brief Delegate for Contextual menu
 */
@protocol MLContextualMenuDelegate <NSObject>

/**
 *  @brief Called when item(bouble) selected
 *
 *  @param contextualMenu the contextual menu
 *
 *  @param selectedIndex of item selected
 *
 *  @param point where user tap
 */
- (void)contextualMenu:(MLContextualMenu *)contextualMenu didSelectItemAtIndex:(NSInteger)selectedIndex atPoint:(CGPoint)point;

@optional
/**
 *  @brief call when contextualMenu close
 *
 *  @param contextualMenu the contextual menu
 */
- (void)contextualMenuDidClose:(MLContextualMenu *)contextualMenu;

@end
