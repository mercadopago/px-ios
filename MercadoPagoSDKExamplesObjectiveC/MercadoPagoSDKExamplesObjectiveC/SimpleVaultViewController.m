//
//  SimpleVaultViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "SimpleVaultViewController.h"
#import "SimpleVaultFormViewController.h"


@import MercadoPagoSDK;

@interface SimpleVaultViewController ()

@end

@implementation SimpleVaultViewController

@synthesize selectedPaymentMethod;
@synthesize customerCard;
@synthesize allowInstallmentsSelection;
NSArray<PaymentMethod *> *currentPaymentMethods;

- (void)viewDidLoad {
//    [super viewDidLoad];
//    [MercadoPagoServices getPaymentMethods:^(NSArray<PaymentMethod *> *paymentMethods) {
//        currentPaymentMethods = paymentMethods;
//        [[self tableView] reloadData];
//        
//    } failure:^(NSError *error) {
//        
//    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentPaymentMethods count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PaymentMethod *pm = currentPaymentMethods[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPPaymentMethodSelection"];
    
    UIImageView* pmIcon = [cell viewWithTag:1];
    pmIcon.image = [MercadoPago getImage:pm.paymentMethodId bundle: [MercadoPago getBundle]];
    
    UILabel *pmTitle = [cell viewWithTag:2];
    pmTitle.text = pm.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedPaymentMethod = currentPaymentMethods[indexPath.row];
    [self performSegueWithIdentifier:@"paymentFormSegue" sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SimpleVaultFormViewController *simpleFormVc= (SimpleVaultFormViewController*) [segue destinationViewController];
    simpleFormVc.paymentMethod = self.selectedPaymentMethod;
    simpleFormVc.allowInstallmentsSelection = self.allowInstallmentsSelection;
    

}




@end
