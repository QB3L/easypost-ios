//
//  Base64Encoder.h
//  EasyPostSample
//
//  Created by Ruben Nieves on 6/4/16.
//  Copyright © 2016 TopBalance Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Encoder : NSObject
+ (NSString *)base64EncodeForData:(NSData *)dataToEncode;
@end
