//
// MLTitledSingleLineStringProvider.h
// Pods
//
// Created by Samuel Sainz on 8/30/17.
//
//

#import <Foundation/Foundation.h>

@interface MLTitledSingleLineStringProvider : NSObject

/**
 *  Returns localized string for a key
 *
 *  @param key for a localized string
 *
 *  @return localized string
 */
+ (NSString *)localizedString:(NSString *)key;

@end
