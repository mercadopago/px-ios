//
// MLStyleSheetManager.h
// MercadoLibre
//
// Created by Cristian Leonel Gibert on 1/18/18.
//

#import <Foundation/Foundation.h>
#import "MLStyleSheetDefault.h"
#import "MLStyleSheetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
   This class is to manage the single style sheet that
   all the UI components are going to use later
 */
@interface MLStyleSheetManager : NSObject

/**
   This property is the style sheet it could be custom or de default
   colors and font
 */
@property (class, nonatomic, strong) id <MLStyleSheetProtocol> styleSheet;

@end

NS_ASSUME_NONNULL_END
