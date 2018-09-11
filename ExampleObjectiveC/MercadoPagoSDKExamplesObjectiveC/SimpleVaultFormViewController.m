//
//  SimpleVaultFormViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "SimpleVaultFormViewController.h"
#import "InstallmentsTableViewController.h"
#import "ExampleUtils.h"

@implementation SimpleVaultFormViewController 

@synthesize customerCard;
@synthesize allowInstallmentsSelection;
@synthesize amount;
UIImageView *cardIcon;
UITextView *cardNumber;
UITextView *securityCode;
UITextView *expirationMonth;
UITextView *expirationYear;
UITextView *cardholderName;
UITextView *identificationNumber;
UILabel *installmentsTitle;
UILabel *identificationType;


- (IBAction)payButtonAction:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = (allowInstallmentsSelection) ? 1 : 0;
    if (self.customerCard != nil) {
        return rows + 2;
    }
    return rows + 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            if (self.customerCard == nil) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPCardNumber"];
                cardIcon = [cell viewWithTag:1];
                cardNumber = [cell viewWithTag:2];
                return cell;
            }
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPCustomerCard"];
            cardIcon = [cell viewWithTag:1];
            return cell;
            }
            break;
        case 1:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPSecurityCode"];
            securityCode = [cell viewWithTag:1];
            return cell;
        }
            break;
        case 2:{
            if (self.customerCard == nil) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPExpirationDate"];
                expirationMonth = [cell viewWithTag:1];
                expirationYear = [cell viewWithTag:2];
                return cell;
            }
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPInstallment"];;
            return cell;

        }
            break;
        case 3:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPCardholderName"];
            cardholderName = [cell viewWithTag:1];
            return cell;
        }
            break;
        case 4:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPIdentification"];
            identificationType = [cell viewWithTag:1];
            identificationNumber = [cell viewWithTag:2];
            return cell;
        }
            break;
        case 5:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPInstallmentsSelection"];
            installmentsTitle = [cell viewWithTag:1];
            return cell;
            
        }
        break;
        default:
            break;
    }

    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self clearFields];

}

-(void) clearFields{
    cardNumber.backgroundColor = [UIColor whiteColor];
    securityCode.backgroundColor = [UIColor whiteColor];
    cardholderName.backgroundColor = [UIColor whiteColor];
    identificationNumber.backgroundColor = [UIColor whiteColor];
    installmentsTitle.textColor = [UIColor darkGrayColor];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier  isEqual: @"displayInstallmentsSegue"]) {
        InstallmentsTableViewController *installmentsVC = [segue destinationViewController];
        installmentsVC.card = customerCard;
        installmentsVC.amount = self.amount;
    }
    
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    InstallmentsTableViewController *installmentsVC = [segue sourceViewController];
    [[self tableView] reloadData];
    
}


@end
