//
//  CustomItemTableViewCell.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 2/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MercadoPagoSDKV4;

@interface CustomItemTableViewCell : UITableViewCell<MPCellContentProvider>

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;

@end
