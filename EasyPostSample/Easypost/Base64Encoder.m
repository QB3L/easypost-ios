//
//  Base64Encoder.m
//  EasyPostSample
//
//  Created by Ruben Nieves on 6/4/16.
//  Copyright © 2016 TopBalance Software. All rights reserved.
//

#import "Base64Encoder.h"
static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
@implementation Base64Encoder
+ (NSString *)base64EncodeForData:(NSData *)dataToEncode;
{
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    unsigned char * working = (unsigned char *)[dataToEncode bytes];
    NSUInteger srcLen = [dataToEncode length];
    for (int i=0; i<srcLen; i += 3) {
        for (int nib=0; nib<4; nib++) {
            int byt = (nib == 0)?0:nib-1;
            int ix = (nib+1)*2;
            if (i+byt >= srcLen) break;
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
            [dest appendFormat:@"%c", base64[curr]];
        }
    }
    return dest;
}
@end
