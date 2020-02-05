//
//  SimpleVaultViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "SimpleVaultViewController.h"
#import "SimpleVaultFormViewController.h"

@interface SimpleVaultViewController ()

@end

@implementation SimpleVaultViewController

@synthesize customerCard;
@synthesize allowInstallmentsSelection;

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
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPPaymentMethodSelection"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"paymentFormSegue" sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SimpleVaultFormViewController *simpleFormVc= (SimpleVaultFormViewController*) [segue destinationViewController];
    simpleFormVc.allowInstallmentsSelection = self.allowInstallmentsSelection;
}

@end
