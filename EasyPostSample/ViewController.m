//
//  ViewController.m
//  EasyPostSample
//
//  Created by Ruben Nieves on 5/21/14.
//  Copyright (c) 2014 TopBalance Software. All rights reserved.
//

#import "ViewController.h"
#import "EasyPost.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _generatingView.hidden = NO;
    [_activity startAnimating];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
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
    
    __weak ViewController *me = self;
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
                          me.postImage.image = image;
                      } else {
                        NSLog(@"Error downloading postage = %@", error);
                      }
                  }
              }];
          } else {
              NSLog(@"No rates found!");
          }
      }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
