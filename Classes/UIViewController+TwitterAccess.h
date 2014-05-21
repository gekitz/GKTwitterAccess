//
// Created by Georg Kitz on 10/04/14.
// Copyright (c) 2014 Tracr Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , GKTwitterAccessErrorCode) {
    GKTwitterAccessErrorCodeNoTwitterAccounts = -1443,
    GKTwitterAccessErrorCodeUserCancelledActionSheet = -1444
};

@class ACAccount;

typedef void(^TRTwitterAuthorizationFinishedBlock)(BOOL granted, NSError *error, ACAccount *account);
@interface UIViewController (TwitterAccess)
- (void)authorizeTwitterAccount:(TRTwitterAuthorizationFinishedBlock)finishedBlock;
@end