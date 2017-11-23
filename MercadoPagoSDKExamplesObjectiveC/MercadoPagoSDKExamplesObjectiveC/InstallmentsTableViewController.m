//
//  InstallmentsTableViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 5/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "InstallmentsTableViewController.h"
#import "SimpleVaultFormViewController.h"
@import MercadoPagoSDK;

@interface InstallmentsTableViewController ()


@end

@implementation InstallmentsTableViewController
@synthesize card;
@synthesize amount;
NSArray<Installment *> *currentInstallments;
@synthesize selectedPayerCost;

- (void)viewDidLoad {
    [super viewDidLoad];
//    [MercadoPagoServices getInstallments:card.firstSixDigits amount:(amount) issuer:card.issuer paymentMethodId:card.paymentMethod._id success:^(NSArray<Installment *> *installments) {
//        currentInstallments = installments;
//        [[self tableView] reloadData];
//    } failure:^(NSError *error) {
//       
//    }];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return currentInstallments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPInstallment" forIndexPath:indexPath];
    
    PayerCost *payerCost = currentInstallments[0].payerCosts[indexPath.row];
    cell.textLabel.text = payerCost.recommendedMessage;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedPayerCost = currentInstallments[0].payerCosts[indexPath.row];
    [self performSegueWithIdentifier:@"unwindToForm" sender:self];
}



@end
