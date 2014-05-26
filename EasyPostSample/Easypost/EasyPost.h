//
//  EasyPost.h
//  EasyPostSample
//
//  Created by Ruben Nieves on 5/21/14.
//  Copyright (c) 2014 TopBalance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#define showNetworkIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define hideNetworkIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define TEST_VERSION 1
extern NSString * const EasyPostServiceErrorDomain;
typedef void (^CompletionHandlerBlock)(NSError *error, NSDictionary *result);

typedef enum {
	EasyPostServiceErrorGeneral					= 1, /* Non-specific error */
	EasyPostServiceErrorMissingParameters		= 2
} EasyPostServiceErrorCode;

@interface EasyPost : NSObject
+ (void)getPostageLabelForShipment:(NSString *)shipmentId atRate:(NSString *)rateId withCompletionHandler:(CompletionHandlerBlock)completionHandler;
+ (void)getAddress:(NSMutableDictionary *)addressDict withCompletionHandler:(CompletionHandlerBlock)successBlock;
+ (void)getParcel:(NSMutableDictionary *)parcelDict withCompletionHandler:(CompletionHandlerBlock)completionHandler;
+ (void)getShipmentTo:(NSString *)toAddressId from:(NSString *)fromAddressId forParcel:(NSString *)parcelId customsInfo:(NSString *)customsId withCompletionHandler:(CompletionHandlerBlock)completionHandler;
+ (void)getShipmentTo:(NSMutableDictionary *)toAddress from:(NSMutableDictionary *)fromAddress forParcel:(NSMutableDictionary *)parcelDictionary withCompletionHandler:(CompletionHandlerBlock)completionHandler;
@end
