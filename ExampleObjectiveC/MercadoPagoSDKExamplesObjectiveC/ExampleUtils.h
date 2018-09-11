//
//  ExampleUtils.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 30/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExampleUtils : NSObject

#define TEST_PUBLIC_KEY @"TEST-ad365c37-8012-4014-84f5-6c895b3f8e0a" //Descuento por codigo "PRUEBA"
#define TEST_PUBLIC_KEY_DISCOUNT @"TEST-85a140f5-10ce-4d3a-ba7a-a743e066840f"
#define MERCHANT_PUBLIC_KEY @"TEST-ad365c37-8012-4014-84f5-6c895b3f8e0a"
//#define TEST_PUBLIC_KEY @"6c0d81bc-99c1-4de8-9976-c8d1d62cd4f2"
#define MERCHANT_MOCK_BASE_URL @"https://www.mercadopago.com"
#define MERCHANT_MOCK_GET_CUSTOMER_URI @"/checkout/examples/getCustomer"
#define MERCHANT_MOCK_CREATE_PAYMENT_URI @"/checkout/examples/doPayment"
#define MERCHANT_MOCK_GET_DISCOUNT_URI @"/checkout/examples/getDiscounts"
#define MERCHANT_ACCESS_TOKEN @"mla-cards-data"
#define AMOUNT 1000.00
#define ITEM_ID @"id1"
#define ITEM_TITLE @"This is the title for an item purchased, extremely long so you can test how a long title will be displayed in the app"
#define ITEM_QUANTITY 1
#define ITEM_UNIT_PRICE 1000.00
#define PREF_ID_NO_EXCLUSIONS @"150216849-e131b785-10d3-48c0-a58b-2910935512e0"//@"150216849-e131b785-10d3-48c0-a58b-2910935512e0"
//#define PREF_ID_NO_EXCLUSIONS @"137787120-eb0b9980-a664-4f8f-9097-580168ed64f0"
#define CURRENCY @"ARS"


@end
