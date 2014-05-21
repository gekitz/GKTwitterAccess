//
//  GKViewController.m
//  GKTwitterAccess
//
//  Created by Georg Kitz on 20/05/14.
//  Copyright (c) 2014 Aurora Apps. All rights reserved.
//

@import Accounts;

#import "GKViewController.h"
#import "UIViewController+TwitterAccess.h"

@interface GKViewController ()

@end

@implementation GKViewController

- (IBAction)accessTwitterAccounts:(id)sender {

    [self authorizeTwitterAccount:^(BOOL granted, NSError *error, ACAccount *account) {
        NSLog(@"Granted %d Error %@ Account %@", granted, error, account.username);
    }];
}

@end
