//
//  EasyPost.m
//  EasyPostSample
//
//  Created by Ruben Nieves on 5/21/14.
//  Copyright (c) 2014 TopBalance Software. All rights reserved.
//

#import "EasyPost.h"
#import "Base64Encoder.h"

#if (TEST_VERSION)
NSString * const APIKEY                                     = @""; //Test Key
#else
NSString * const APIKEY                                     = @"";
#endif
NSString * const EasyPostServiceErrorDomain					= @"EasyPostServiceError";


@implementation EasyPost

#pragma mark - Special Methods
+ (void)requestServiceForParameters:(NSMutableDictionary *)paramsDictionary atLink:(NSString *)link withHandler:(CompletionHandlerBlock)completionHandler
{
    NSMutableString *body = [NSMutableString stringWithCapacity:255];
    [paramsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [body appendFormat:@"%@=%@&", key, obj];
    }];
    NSString *method = @"GET";
    if ([[paramsDictionary allKeys] count] > 0) {
        [body deleteCharactersInRange:NSMakeRange([body length]-1, 1)]; //Delete last & character
        method = @"POST";
    }
    
    
    NSData *requestData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:link]];
    
    //Authorization
    NSString *authStr = [NSString stringWithFormat:@"%@:", APIKEY];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@=", [Base64Encoder base64EncodeForData:authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    //Finish request
    NSString *postLength = [NSString stringWithFormat:@"%d", [requestData length]];
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionUploadTask *uploadTask =  [session uploadTaskWithRequest:request fromData:requestData  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)   {
        //handle response
        if (error) {
            completionHandler(error, nil);
        } else {
            NSError *jsonError = nil;
            NSDictionary *returnData =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingAllowFragments
                                              error:&jsonError];
            completionHandler(jsonError, returnData);
            

        }
    }];
    [uploadTask resume];
    
}

#pragma mark - Class Methods
+ (void)getPostageLabelForShipment:(NSString *)shipmentId atRate:(NSString *)rateId withCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    if (!rateId || !shipmentId) {
        NSError *error = [NSError errorWithDomain:EasyPostServiceErrorDomain code:EasyPostServiceErrorMissingParameters userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing required parameters", NSLocalizedDescriptionKey, nil]];
        completionHandler(error,nil);
        return;
    }
    NSString *link = [NSString stringWithFormat:@"https://api.easypost.com/v2/shipments/%@/buy",shipmentId];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 rateId, @"rate[id]",
                                 nil];
    
    [EasyPost requestServiceForParameters:dict atLink:link withHandler:completionHandler];
}



+ (void)getAddress:(NSMutableDictionary *)addressDict withCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    [EasyPost requestServiceForParameters:addressDict atLink:@"https://api.easypost.com/v2/addresses" withHandler:completionHandler];
}

+ (void)getParcel:(NSMutableDictionary *)parcelDict withCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    [EasyPost requestServiceForParameters:parcelDict atLink:@"https://api.easypost.com/v2/parcels" withHandler:completionHandler];
}


+ (void)getShipmentTo:(NSString *)toAddressId from:(NSString *)fromAddressId forParcel:(NSString *)parcelId customsInfo:(NSString *)customsId withCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    if (!toAddressId || !fromAddressId || !parcelId) {
        NSError *error = [NSError errorWithDomain:EasyPostServiceErrorDomain code:EasyPostServiceErrorMissingParameters userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Missing required parameters", NSLocalizedDescriptionKey, nil]];
        completionHandler(error,nil);
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 toAddressId, @"shipment[to_address][id]",
                                 fromAddressId, @"shipment[from_address][id]",
                                 parcelId, @"shipment[parcel][id]",
                                 nil];
    if (customsId) {
        [dict setValue:customsId forKey:@"shipment[customs_info][id]"];
    }
    [EasyPost requestServiceForParameters:dict atLink:@"https://api.easypost.com/v2/shipments" withHandler:completionHandler];
}


+ (void)getShipmentTo:(NSMutableDictionary *)toAddress from:(NSMutableDictionary *)fromAddress forParcel:(NSMutableDictionary *)parcelDictionary withCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    //Add addresses values for shipment
    for (int i = 0; i < 2; i++) {
        NSMutableDictionary *addressDict = i == 0 ? fromAddress : toAddress;
        NSString *addressKeyString = i == 0 ? @"from_address" : @"to_address";
        
        NSString *name = [addressDict valueForKey:@"address[name]"];
        if (name) {
            [dict setValue:name forKey:[NSString stringWithFormat:@"shipment[%@][name]",addressKeyString]];
        }
        
        NSString *company = [addressDict valueForKey:@"address[company]"];
        if (company) {
            [dict setValue:company forKey:[NSString stringWithFormat:@"shipment[%@][company]",addressKeyString]];
        }
        
        NSString *street1 = [addressDict valueForKey:@"address[street1]"];
        if (street1) {
            [dict setValue:street1 forKey:[NSString stringWithFormat:@"shipment[%@][street1]",addressKeyString]];
        }
        NSString *street2 = [addressDict valueForKey:@"address[street2]"];
        if (street2) {
            [dict setValue:street2 forKey:[NSString stringWithFormat:@"shipment[%@][street2]",addressKeyString]];
        }
        
        NSString *city = [addressDict valueForKey:@"address[city]"];
        if (city) {
            [dict setValue:city forKey:[NSString stringWithFormat:@"shipment[%@][city]",addressKeyString]];
        }
        
        NSString *state = [addressDict valueForKey:@"address[state]"];
        if (state) {
            [dict setValue:state forKey:[NSString stringWithFormat:@"shipment[%@][state]",addressKeyString]];
        }
        
        NSString *zip = [addressDict valueForKey:@"address[zip]"];
        if (zip) {
            [dict setValue:zip forKey:[NSString stringWithFormat:@"shipment[%@][zip]",addressKeyString]];
        }
        
        NSString *country = [addressDict valueForKey:@"address[country]"];
        if (country) {
            [dict setValue:country forKey:[NSString stringWithFormat:@"shipment[%@][country]",addressKeyString]];
        } else {
            [dict setValue:@"US" forKey:[NSString stringWithFormat:@"shipment[%@][country]",addressKeyString]];
        }
        
        NSString *phone = [addressDict valueForKey:@"address[phone]"];
        if (phone) {
            [dict setValue:phone forKey:[NSString stringWithFormat:@"shipment[%@][phone]",addressKeyString]];
        }
        
        NSString *email = [addressDict valueForKey:@"address[email]"];
        if (email) {
            [dict setValue:email forKey:[NSString stringWithFormat:@"shipment[%@][email]",addressKeyString]];
        }
    }
    
    
    NSString *predefinedPackage = [parcelDictionary valueForKey:@"parcel[predefined_package]"];
    if (predefinedPackage) {
        [dict setValue:predefinedPackage forKey:@"shipment[parcel][predefined_package]"];
    }
    
    NSString *weight = [parcelDictionary valueForKey:@"parcel[weight]"];
    if (weight) {
        [dict setValue:weight forKey:@"shipment[parcel][weight]"];
    }
    
    NSString *length = [parcelDictionary valueForKey:@"parcel[length]"];
    if (length) {
        [dict setValue:length forKey:@"shipment[parcel][length]"];
    }
    
    NSString *width = [parcelDictionary valueForKey:@"parcel[width]"];
    if (width) {
        [dict setValue:width forKey:@"shipment[parcel][width]"];
    }
    
    NSString *height = [parcelDictionary valueForKey:@"parcel[height]"];
    if (height) {
        [dict setValue:height forKey:@"shipment[parcel][height]"];
    }
    
    [EasyPost requestServiceForParameters:dict atLink:@"https://api.easypost.com/v2/shipments" withHandler:completionHandler];

}


@end
