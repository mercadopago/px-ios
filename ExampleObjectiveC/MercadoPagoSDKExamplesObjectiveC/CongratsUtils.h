//
//  CongratsUtils.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Franco Risma on 14/08/2020.
//  Copyright © 2020 MercadoPago. All rights reserved.
//

#ifndef CongratsUtils_h
#define CongratsUtils_h

#import <Foundation/Foundation.h>
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"

@interface CongratsUtils: NSObject

+(PXPoints *)points;
+(PXDiscounts *)discount;
+(NSArray<PXCrossSellingItem*>*)crossSelling;
+(PXExpenseSplit *)expenseSplit;
+(PXCongratsPaymentInfo *)paymentInfo;
+(PXCongratsPaymentInfo *)splitPaymentInfo;
+(PXPaymentCongratsTracking *)trackingProperties;
+(PXTrackingConfiguration *)trackingConfiguration:(id<PXTrackerListener>)trackListener;

@end

#endif /* CongratsUtils_h */

@interface CongratsExample: NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) PXPaymentCongrats *data;

- (instancetype)initWithTitle:(NSString*) title andData:(PXPaymentCongrats *) data;

@end
