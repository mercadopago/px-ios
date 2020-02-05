//
//  MediosOffTableViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 7/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MediosOffTableViewController.h"


@implementation MediosOffTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableSet* conjunto = [[NSMutableSet alloc] init];
    [conjunto addObject:@"credit_card"];
    [conjunto addObject:@"debit_card"];

    
    
//   
//    [MercadoPagoServices getPaymentMethods:^(NSArray<PaymentMethod *> *paymentMethods) {
//        self.mediosOffArray = [[NSMutableArray alloc]init];
//        
//        [paymentMethods enumerateObjectsUsingBlock:^(PaymentMethod * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(obj.paymentTypeId);
//            if (![conjunto containsObject:obj.paymentTypeId]){
//                [self.mediosOffArray addObject:obj];
//            }
//        }];
//        [[self tableView] reloadData];
//    } failure:^(NSError *error) {
//        
//    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediosOffCell" forIndexPath:indexPath];
   
    UIImageView* image = [cell viewWithTag:1];
    UILabel* label = [cell viewWithTag:2];

    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}




-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"unwindFromOff" sender:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
