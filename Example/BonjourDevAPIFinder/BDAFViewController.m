//
//  BDAFViewController.m
//  BonjourDevAPIFinder
//
//  Created by Tomek Kopczuk on 11/28/2014.
//  Copyright (c) 2014 Tomek Kopczuk. All rights reserved.
//

#import <BonjourDevAPIFinder/BonjourDevAPIFinder.h>

#import "BDAFViewController.h"

@interface BDAFViewController ()

@property (weak, nonatomic) IBOutlet UITextField *apiAddressLabel;

@end

@implementation BDAFViewController

+ (NSString*)baseAPIAddress
{
    return [BonjourDevAPIFinder.sharedInstance apiAddressForIdentifier:@"example"
                                                     defaultAPIAddress:@"api.example.com"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BonjourDevAPIFinder.sharedInstance addApiService:@"API server"
                                           identifier:@"example"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self apiAddressLabel].text = [BDAFViewController baseAPIAddress];
}

@end
