//
//  CongratsExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Franco Risma on 14/08/2020.
//  Copyright © 2020 MercadoPago. All rights reserved.
//

#import "CongratsExamplesViewController.h"
#import "CongratsUtils.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"

@interface CongratsExamplesViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CongratsExample *> *examples;

@end

@implementation CongratsExamplesViewController

- (void)loadView {
    [self setupExamples];
    [self setupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.view = self.tableView;
}

- (void)setupExamples {
    self.examples = [[NSMutableArray alloc] init];
    [self.examples addObject:[[CongratsExample alloc] initWithTitle:@"Full" andData:[self fullCongrats]]];
}

- (PXPaymentCongrats *)fullCongrats {
    __weak CongratsExamplesViewController *weakSelf = self;
    return [[[[[[[[[[[[[[[[PXPaymentCongrats alloc] init] withCongratsType:PXCongratsTypeAPPROVED]
                         withHeaderWithTitle:@"¡Listo! Ya le pagaste a SuperMarket" imageURL:@"https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg" closeAction:^{
        [weakSelf.navigationController popViewControllerAnimated:TRUE];
    }]
                        withReceiptWithShouldShowReceipt:TRUE receiptId:@"1234" action:nil]
                       withLoyalty:CongratsUtils.points]
                      withDiscounts:CongratsUtils.discount]
                     withExpenseSplit:CongratsUtils.expenseSplit]
                    withCrossSelling:CongratsUtils.crossSelling]
                   withFooterMainAction: [[PXAction alloc] initWithLabel:@"Continuar" action:^{
        [weakSelf.navigationController popViewControllerAnimated:TRUE];
    }]]
                  withFooterSecondaryAction: nil]
                 withCreditsExpectationView:nil]
                shouldShowPaymentMethod:TRUE]
               withPaymentMethodInfo:CongratsUtils.paymentInfo]
              withSplitPaymentInfo:CongratsUtils.splitPaymentInfo]
            withTrackingWithTrackingProperties:[CongratsUtils trackingProperties:self]];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *exampleTitle = [self.examples objectAtIndex:indexPath.row].title;
    cell.textLabel.text = exampleTitle;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.examples count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PXPaymentCongrats *example = [self.examples objectAtIndex:indexPath.row].data;
    [example startUsing: self.navigationController];
}

- (void)trackEventWithScreenName:(NSString * _Nullable)screenName action:(NSString * _Null_unspecified)action result:(NSString * _Nullable)result extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track event
}

- (void)trackScreenWithScreenName:(NSString * _Nonnull)screenName extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track screen
}

@end
