//
//  SavedCardsTableViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedCardsTableViewController : UITableViewController

@property NSArray<PXCard *> *cards;
@property bool allowInstallmentsSeletion;

@end
