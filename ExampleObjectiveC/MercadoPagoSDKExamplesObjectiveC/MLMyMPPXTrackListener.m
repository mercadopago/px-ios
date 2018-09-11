//
// MLMyMPPXTrackListener.m
//
// Created by Tomi De Lucca on 21/2/18.
// Copyright © 2018 MercadoPago. All rights reserved.
//

#import "MLMyMPPXTrackListener.h"

@implementation MLMyMPPXTrackListener

- (void)trackScreenWithScreenName:(NSString *)screenName extraParams:(NSDictionary *)extraParams
{
    // Melidata usually uses lowercase strings
    NSString *path = [[NSString stringWithFormat:@"/px/%@", screenName] lowercaseString];
}

- (void)trackEventWithScreenName:(NSString *)screenName action:(NSString *)action result:(NSString *)result extraParams:(NSDictionary *)extraParams
{
    // Melidata usually uses lowercase strings
    screenName = [screenName lowercaseString];
    action = [action lowercaseString];
    result = [result lowercaseString];

    NSString *track = @"";
    if (action && screenName) {
        track = [NSString stringWithFormat:@"%@/%@", screenName, action];
    } else if (action) {
        track = [NSString stringWithFormat:@"/%@", action];
    }
}
@end
