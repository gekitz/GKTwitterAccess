Description
=======

This addition tries to access the Twitter accounts a user has defined
in the Settings.app. If the user has multiple accounts, an `UIActionSheet`
is presented and the user can pick one account, otherwise if only one account
is defined, said account is returned in the completion block.

You simply have to call following method
```objc
@interface UIViewController (TwitterAccess)
- (void)authorizeTwitterAccount:(TRTwitterAuthorizationFinishedBlock)finishedBlock;
@end
```

If the user has no Twitter accounts defined in the Settings.app we return
`GKTwitterAccessErrorCodeNoTwitterAccounts`as error.

If the user presses cancel while the `UIActionSheet` is shown, we return
 `GKTwitterAccessErrorCodeUserCancelledActionSheet` as error.

 Finally if any other error occurs during the authorization process, we return
 the error we get from the framework.

Possible Scenarios
=======

No Twitter Accounts -> Error </br>
One/More Twitter Accounts -> Access Denied -> Error </br>
One Twitter Account -> Access Granted -> Account is returned </br>
More Twitter Accounts -> Access Granted -> UIActionSheet is shown -> Picked Account is returned </br>


Author
======
 Georg Kitz, [@gekitz](http://twitter.com/gekitz)
