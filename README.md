easypost-ios
============

Simple implementation of the EasyPost API for iOS. Generate postage easily.



Install
=================

1. Load all files under EasyPost folder in sample project to your own project.
2. `#import "EasyPost.h"`
3. Swift Version included as well in sample project.


Usage
=================


1. Create sender, recipient and parcel dictionaries
--------------------

```
	NSMutableDictionary *fromDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"Steve Jobs",@"address[name]",
                                           @"",@"address[company]",
                                           @"1 Infinite Loop",@"address[street1]",
                                           @"",@"address[street2]",
                                           @"Cupertino",@"address[city]",
                                           @"CA",@"address[state]",
                                           @"95014",@"address[zip]",
                                           @"US",@"address[country]",
                                           @"(408)974-5050",@"address[phone]",
                                           @"steve@apple.com",@"address[email]",
                                           nil];
    
    NSMutableDictionary *toDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"Bill Gates",@"address[name]",
                                         @"",@"address[company]",
                                         @"1 Microsoft Way",@"address[street1]",
                                         @"",@"address[street2]",
                                         @"Redmond",@"address[city]",
                                         @"WA",@"address[state]",
                                         @"98052",@"address[zip]",
                                         @"US",@"address[country]",
                                         @"(425)882-8080",@"address[phone]",
                                         @"bill@microsoft.com",@"address[email]",
                                         nil];
    
    NSMutableDictionary *parcelDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"8",@"parcel[length]",
                                             @"6",@"parcel[width]",
                                             @"5",@"parcel[height]",
                                             @"10",@"parcel[weight]",
                                             nil];
```
 
2. Use convenience methods to get data for postage
--------------------
```

[EasyPost getShipmentTo:toDictionary from:fromDictionary forParcel:parcelDictionary
      withCompletionHandler:^(NSError *error, NSDictionary *result) {
          NSLog(@"Result: %@",result);
          //Get rateId here
          NSArray *rates = [result valueForKey:@"rates"];
          NSString *shipmentId = [result valueForKey:@"id"];
          if (rates.count > 0) {
              
              NSDictionary *firstRate = [rates objectAtIndex:0];
              NSString *firstRateId = [firstRate valueForKey:@"id"];
              
              [EasyPost getPostageLabelForShipment:shipmentId atRate:firstRateId withCompletionHandler:^(NSError *error, NSDictionary *result) {
                  [me.activity stopAnimating];
                  me.generatingView.hidden = YES;
                  if (error) {
                      //Show some error
                  } else {
                      NSDictionary *postageDict = [result objectForKey:@"postage_label"];
                      NSString *postageURL = [postageDict valueForKey:@"label_url"];
                      NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:postageURL]];
                      NSError *error = nil;
                      //Data returned is a txt file
                      NSHTTPURLResponse* response = nil;
                    
                      //Using synchronous request for convenience
                      NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                      
                      if (returnData && !error) {
                          UIImage *image = [UIImage imageWithData:returnData];
                      } else {
                        NSLog(@"Error downloading postage = %@", error);
                      }
                  }
              }];
          } else {
              NSLog(@"No rates found!");
          }
      }];
      
```      

3. Get image of postage!
--------------------
![easypost-ios](http://www.topbalancesoftware.com/apps/gitmedia/easypost_sample.gif)



MIT License
--------------------
    The MIT License (MIT)

    Copyright (c) 2014 Ruben Nieves

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.