//
//  SavedCardsTableViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "SavedCardsTableViewController.h"
#import "ExampleUtils.h"
#import "SimpleVaultFormViewController.h"


@implementation SavedCardsTableViewController

@synthesize cards;
@synthesize allowInstallmentsSeletion;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [MercadoPagoContext setCustomerURI:MERCHANT_MOCK_GET_CUSTOMER_URI];
//    [CustomServer getCustomer:^(Customer * customer) {
//        self.cards = customer.cards;
//        [self.tableView reloadData];
//    } failure:^(NSError * error) {
//        
//    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cards.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SavedCardCell" forIndexPath:indexPath];
    UIImageView *pmIcon = [cell viewWithTag:1];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showVaultFormSegue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SimpleVaultFormViewController *form = [segue destinationViewController];
    form.allowInstallmentsSelection = self.allowInstallmentsSeletion;
    form.amount = 100.00;
}


@end
