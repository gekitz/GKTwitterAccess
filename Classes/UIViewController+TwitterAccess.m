//
// Created by Georg Kitz on 10/04/14.
// Copyright (c) 2014 Tracr Ltd. All rights reserved.
//

@import Accounts;
@import Social;

#import <objc/runtime.h>

#import "UIViewController+TwitterAccess.h"
#import "UIActionSheet+GKBlockAddition.h"

static NSString *const kErrorDomain = @"twitter.access.error";
static void *kFinishBlock = &kFinishBlock;

@interface UIViewController (TwitterAccessInternal)
@property (nonatomic, copy) TRTwitterAuthorizationFinishedBlock gk_finishedBlock;
@end

@implementation UIViewController (TwitterAccess)

#pragma mark -
#pragma mark Property

- (void)setGk_finishedBlock:(TRTwitterAuthorizationFinishedBlock)gk_finishedBlock {
    objc_setAssociatedObject(self, kFinishBlock, gk_finishedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TRTwitterAuthorizationFinishedBlock)gk_finishedBlock {
    return objc_getAssociatedObject(self, kFinishBlock);
}

#pragma mark -
#pragma mark Public Methods

- (void)authorizeTwitterAccount:(TRTwitterAuthorizationFinishedBlock)finishedBlock {

    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {

        NSError *error = [NSError errorWithDomain:kErrorDomain code:GKTwitterAccessErrorCodeNoTwitterAccounts userInfo:nil];
        finishedBlock(NO, error, nil);

        return;
    }

    self.gk_finishedBlock = finishedBlock;

    [self _gk_internalAuthorizeTwitterAccount];
}

#pragma mark -
#pragma mark Private Methods

- (void)_gk_internalAuthorizeTwitterAccount {
    ACAccountStore *store = [ACAccountStore new];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    __weak typeof(self) weakSelf = self;
    [store requestAccessToAccountsWithType:type options:nil completion:^(BOOL granted, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (granted && !error) {
                [weakSelf _gk_handleAccessGranted];
            } else {
                [weakSelf _gk_handleAccessDenied:error];
            }
        });
    }];
}

- (void)_gk_handleAccessGranted {

    ACAccountStore *store = [ACAccountStore new];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [store accountsWithAccountType:type];

    if ( accounts.count > 1 ) {
        [self _gk_showAccountSelectionSheetForAccounts:accounts];
    } else {
        self.gk_finishedBlock(YES, nil, accounts.firstObject);
    }
}

- (void)_gk_showAccountSelectionSheetForAccounts:(NSArray *)accounts {

    //just in case the keyboard is visible
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    __weak typeof(self) weakSelf = self;
    void(^actionBlock)(UIActionSheet *, NSInteger) = ^(UIActionSheet *sheet, NSInteger buttonIndex) {

        if (sheet.cancelButtonIndex == buttonIndex) {

            NSError *error = [NSError errorWithDomain:kErrorDomain code:GKTwitterAccessErrorCodeUserCancelledActionSheet userInfo:nil];
            weakSelf.gk_finishedBlock(NO, error, nil);
            return;
        }
        [weakSelf _gk_handleAccounts:accounts selectedIndex:buttonIndex];
    };

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil block:actionBlock cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    for (ACAccount *account in accounts) {
        NSString *username = [NSString stringWithFormat:@"@%@", account.username];
        [sheet addButtonWithTitle:username];
    }

    NSInteger idx = [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    [sheet setCancelButtonIndex:idx];

    [sheet showInView:self.view];
}

- (void)_gk_handleAccounts:(NSArray *)accounts selectedIndex:(NSInteger)index {
    ACAccount *account = accounts[index];
    self.gk_finishedBlock(YES, nil, account);
}

- (void)_gk_handleAccessDenied:(NSError *)error; {
    self.gk_finishedBlock(NO, error, nil);
}

@end