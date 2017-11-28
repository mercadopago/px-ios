//
//  ThirdHookViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Eden Torres on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MercadoPagoSDK;

@interface ThirdHookViewController : UIViewController  <PXHookComponent>
@property (strong, nonatomic) PXActionHandler * actionHandler;
@end
