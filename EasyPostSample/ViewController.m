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


#pragma mark - Special Methods
- (void)showError:(NSError *)error
{
    self.activityMessage.text = @"Error found!";
    [self.activity stopAnimating];
    self.activity.hidden = YES;
    NSLog(@"%@",error);
}

#pragma mark - Test methods
- (void)createAddress
{
    __weak ViewController *me = self;
    me.activityMessage.text = @"Creating address...";
    [me.activity startAnimating];
    [EasyPost getAddress:me.fromDictionary withCompletionHandler:^(NSError *error, NSDictionary *result) {
        if (error) {
            [me showError:error];
        } else {
            [me.activity stopAnimating];
            me.activityMessage.text = @"Address created";
            NSLog(@"result = %@",result);
        }
    }];
}

- (void)createParcel
{
    __weak ViewController *me = self;
    me.activityMessage.text = @"Creating parcel...";
    [me.activity startAnimating];
    [EasyPost getParcel:me.parcelDictionary withCompletionHandler:^(NSError *error, NSDictionary *result) {
        if (error) {
            [me showError:error];
        } else {
            [me.activity stopAnimating];
            me.activityMessage.text = @"Parcel created";
            NSLog(@"result = %@",result);
        }
    }];
}

- (void)quickLabel
{
    __weak ViewController *me = self;
    me.activityMessage.text = @"Creating shipment...";
    [EasyPost getShipmentTo:me.toDictionary from:me.fromDictionary forParcel:me.parcelDictionary
      withCompletionHandler:^(NSError *error, NSDictionary *result) {
          NSLog(@"Result: %@",result);
          //Get rateId here
          NSArray *rates = [result valueForKey:@"rates"];
          NSString *shipmentId = [result valueForKey:@"id"];
          if (error) {
              [me showError:error];
          } else {
              
              if (rates.count > 0) {
                  NSDictionary *firstRate = [rates objectAtIndex:0];
                  NSString *firstRateId = [firstRate valueForKey:@"id"];
                  me.activityMessage.text = @"Generating label...";
                  [EasyPost getPostageLabelForShipment:shipmentId atRate:firstRateId withCompletionHandler:^(NSError *error, NSDictionary *result) {
                      [me.activity stopAnimating];
                      me.generatingView.hidden = YES;
                      if (error) {
                          [me showError:error];
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
                  me.activityMessage.text = @"No rates found!";
                  [me.activity stopAnimating];
                  me.activity.hidden = YES;
                  NSLog(@"No rates found!");
              }
          }
      }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //Load test dictionaries
    self.fromDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"Steve Jobs",@"address[name]",
                                           @"1 Infinite Loop",@"address[street1]",
                                           @"",@"address[street2]",
                                           @"Cupertino",@"address[city]",
                                           @"CA",@"address[state]",
                                           @"95014",@"address[zip]",
                                           @"US",@"address[country]",
                                           @"(408)974-5050",@"address[phone]",
                                           @"steve@apple.com",@"address[email]",
                                           nil];
    
    self.toDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"Bill Gates",@"address[name]",
                                         @"1 Microsoft Way",@"address[street1]",
                                         @"",@"address[street2]",
                                         @"Redmond",@"address[city]",
                                         @"WA",@"address[state]",
                                         @"98052",@"address[zip]",
                                         @"US",@"address[country]",
                                         @"(425)882-8080",@"address[phone]",
                                         @"bill@microsoft.com",@"address[email]",
                                         nil];
    
    self.parcelDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"8",@"parcel[length]",
                                             @"6",@"parcel[width]",
                                             @"5",@"parcel[height]",
                                             @"10",@"parcel[weight]",
                                             nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    /******************TEST ZONE******************/
    //[self quickLabel];
    //[self createAddress];
    [self createParcel];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
