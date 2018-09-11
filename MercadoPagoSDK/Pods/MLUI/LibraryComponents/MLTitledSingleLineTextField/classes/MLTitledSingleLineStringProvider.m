//
// MLTitledSingleLineStringProvider.m
// Pods
//
// Created by Samuel Sainz on 8/30/17.
//
//

#import "MLTitledSingleLineStringProvider.h"
#import "MLUIBundle.h"

@implementation MLTitledSingleLineStringProvider

+ (NSString *)localizedString:(NSString *)key
{
	return [[MLUIBundle mluiBundle] localizedStringForKey:key value:nil table:@"MLTitledSingleLineTextField"];
}

@end
