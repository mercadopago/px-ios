//
//  AppDelegate.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 30/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleUtils.h"


@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [MercadoPagoContext setPublicKey:@"APP_USR-5a399d42-6015-4f6a-8ff8-dd7d368068f8"];
    
//    [MercadoPagoContext setPublicKey:TEST_PUBLIC_KEY];

//    [MercadoPagoContext setPayerAccessToken:@"APP_USR-1094487241196549-081708-4bc39f94fd147e7ce839c230c93261cb__LA_LC__-145698489"];


//    [MercadoPagoContext setMerchantAccessToken: MERCHANT_ACCESS_TOKEN];
//    [MercadoPagoContext setBaseURL: MERCHANT_MOCK_BASE_URL];
//    [MercadoPagoContext setCustomerURI: MERCHANT_MOCK_GET_CUSTOMER_URI];
    
    //[MercadoPagoContext setAccountMoneyAvailableWithAccountMoneyAvailable:YES];
    
    //[MercadoPagoContext setupPrimaryColor:[UIColor redColor] complementaryColor:nil];
    //[MercadoPagoContext setDisplayDefaultLoadingWithFlag:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
