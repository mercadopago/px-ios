//
//  FirstHookViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 23/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MercadoPagoSDK;

@interface FirstHookViewController : UIViewController  <PXHookComponent>
@property (strong, nonatomic) PXActionHandler * actionHandler;
@end
