//
//  SimpleVaultFormViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleVaultFormViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) PXCard *customerCard;
@property(nonatomic) bool allowInstallmentsSelection;
@property(nonatomic) double amount;

@end
