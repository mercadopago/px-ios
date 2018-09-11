//
//  ServicesExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "ServicesExamplesViewController.h"
#import "SavedCardsTableViewController.h"

@interface ServicesExamplesViewController ()

@end

@implementation ServicesExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier  isEqual: @"allowInstallmentsSegue"]) {
        SavedCardsTableViewController *savedCardsVC = [segue destinationViewController];
        savedCardsVC.allowInstallmentsSeletion = YES;
    }
    
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

@end
