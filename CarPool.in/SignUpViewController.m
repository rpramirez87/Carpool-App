//
//  SignUpViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/27/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "SignUpViewController.h"
#import "FCAlertView.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "DataService.h"

@import FirebaseAuth;
@import FirebaseDatabase;




@interface SignUpViewController () <GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation SignUpViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Google Sign in
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    //Textfield Delegates
    self.nameTextField.delegate = self;
    self.emailAddressTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
}

#pragma mark - Google Sign In

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error == nil) {
        NSLog(@"Successfully Signed in gmail user");
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        //Access profile
        NSString *fullName = user.profile.name;
        NSString *email = user.profile.email;
        NSURL *imageURL = [user.profile imageURLWithDimension:200];
        NSString *stringURL = [imageURL absoluteString];
        
        NSLog(@"Image URL%@", stringURL);
        NSLog(@"fullName - %@", fullName);
        NSLog(@"email ID - %@", email);
        NSLog(@"Provider credential - %@", credential.provider);
        
        
        //Authenticate gmail user through Firebase authentication
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      
                                      //Handle error
                                      if (error) {
                                          NSLog(@"Google Signin Authentication error - %@", error.localizedDescription);
                                          [self alertViewWithMessage:error.localizedDescription];
                                          return;
                                      }
                                      
                                      //Success
                                      NSLog(@"Sucessfully authenticated gmail user");
                                      
                                      //Create public user dictionary
                                      NSDictionary *publicUserDict = @{
                                                                       @"name" : fullName,
                                                                       @"image" : stringURL,
                                                                       };
                                      [[[[DataService ds] publicUserReference]child:user.uid] updateChildValues:publicUserDict];
                                      
                                      //Create a user dictionary
                                      NSDictionary *userDict = @{
                                                                 @"name" : fullName,
                                                                 @"image" : stringURL,
                                                                 @"email": email,
                                                                 @"provider" : credential.provider
                                                                 };
                                      
                                      
                                      [[[[DataService ds] userReference]child:user.uid] updateChildValues:userDict];
                                      
                                      //Load up new view controller
                                      
                                  }];
        
    } else {
        NSLog(@"Error signing in - %@", error.localizedDescription);
        [self alertViewWithMessage:error.localizedDescription];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    [self alertViewWithMessage:error.localizedDescription];
}

#pragma mark - IBAction

- (IBAction)signInButton:(UIButton *)sender {
    NSLog(@"Sign in button pressed");
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)signUpButtonPressed:(UIButton *)sender {
    //Handle name
    if ([self.nameTextField.text isEqualToString:@""]) {
        [self alertViewWithMessage:@"Please enter a valid name"];
        return;
    }
    
    //Handle Email
    if ([self.emailAddressTextField.text isEqual: @""]) {
        [self alertViewWithMessage:@"Please enter a valid email"];
        return;
    }
    
    //Handle Password nil
    if ([self.passwordTextField.text isEqual: @""]) {
        [self alertViewWithMessage:@"Please enter a valid password"];
        return;
    }
    
    //Check if password is equal to confirm password
    if (![self.passwordTextField.text isEqual: self.confirmPasswordTextField.text]) {
        [self alertViewWithMessage:@"Password does not match"];
        return;
    }
    
    NSLog(@"Valid Email");
    [self createEmailUserWith:self.emailAddressTextField.text andPassword:self.passwordTextField.text];
    
}

- (IBAction)facebookButtonPressed:(id)sender {
    FBSDKLoginManager *fbLoginManager = [[FBSDKLoginManager alloc] init];
    
    [fbLoginManager logInWithReadPermissions:@[@"email", @"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error)
        {
            // Process error
            NSLog(@"Facebook Login Error %@", error.localizedDescription);
        }
        else if (result.isCancelled)
        {
            // Handle cancellations
            NSLog(@"Facebook is cancelled");
        }
        else
        {
            NSLog(@"Successfully logged in");
            
            //Graph Request
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                               parameters:@{@"fields": @"id, name, picture, email"}]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSString *pictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result objectForKey:@"id"]];
                     
                     //Print
                     NSLog(@"name is %@",[result objectForKey:@"name"]);
                     NSLog(@"id is %@", [result objectForKey:@"id"]);
                     NSLog(@"picture is %@", pictureURL);
                     NSLog(@"email is %@", [result objectForKey:@"email"]);
                     
                     //Create a token for Firebase authentication
                     NSString *currentToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                     NSLog(@"Current Token - %@", currentToken);
                     FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                                      credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                                      .tokenString];
                     
                     
                     //Create a user dictionary
                     NSDictionary *userDict = @{
                                                @"name" : [result objectForKey:@"name"],
                                                @"image" : pictureURL,
                                                @"email": [result objectForKey:@"email"],
                                                @"provider" : credential.provider
                                                };
                     
                     
                     [self createFacebookuserWithCredential:credential withUserInfo:userDict];
                 }
                 else{
                     NSLog(@"%@", [error localizedDescription]);
                 }
             }];
        }
    }];
}


#pragma mark - Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helper Methods

- (void)alertViewWithMessage:(NSString *)warningMessage {
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeCaution];
    
    [alert showAlertInView:self
                 withTitle:@"Warning"
              withSubtitle:warningMessage
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}

#pragma mark - Firebase Auth

- (void)createEmailUserWith:(NSString *)email andPassword:(NSString *)password {
    
    [[FIRAuth auth] createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error == nil){
            FIRAuthCredential *credential =
            [FIREmailPasswordAuthProvider credentialWithEmail:email
                                                     password:password];
            //Credential Provider shows "password"
            NSLog(@"Credential provider - %@", credential.provider);
            NSLog(@"%@", user.uid);
            
            //Create a user dictionary
            NSDictionary *userDict = @{
                                       @"name" : self.nameTextField.text,
                                       @"email": email,
                                       @"provider" : @"email"
                                       };
            
            NSDictionary *publicUserDict = @{@"name" : self.nameTextField.text};
            
            
            //Update public user
            [[[[DataService ds] publicUserReference]child:user.uid] updateChildValues:publicUserDict];
            
            //Update private user
            [[[[DataService ds] userReference]child:user.uid] updateChildValues:userDict];
            
            NSLog(@"Successfully created email user");
            
            //Send Verification email
            [self sendVerificationToEmail:email];
            
            //Save Keychain as current uid
            //[self keychainSaveWithUID:user.uid];
            
            //Present Main VC
            //            MainVC *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
            //            [self.navigationController pushViewController:mainVC animated:YES];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
            [self alertViewWithMessage:error.localizedDescription];
            return;
        }
    }];
}

- (void)sendVerificationToEmail:(NSString *)email {
    [[FIRAuth auth].currentUser sendEmailVerificationWithCompletion:^(NSError *_Nullable error) {
        
        if(error != nil) {
            [self alertViewWithMessage:error.localizedDescription];
            return;
        }else {
            
            //Create an alert
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert makeAlertTypeSuccess];
            
            [alert showAlertInView:self
                         withTitle:@"Success"
                      withSubtitle:[NSString stringWithFormat:@"Success, user with email (%@) is registered",email]
                   withCustomImage:nil
               withDoneButtonTitle:nil
                        andButtons:nil];
            [alert doneActionBlock:^{
                // Put your action here
                NSLog(@"Email Verified Done");
            }];
        }
    }];
}

-(void)createFacebookuserWithCredential:(FIRAuthCredential *)credential withUserInfo:(NSDictionary *)userDict {
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                  
                                  if (error) {
                                      //Error code for multipler users
                                      if (error.code == 17007) {
                                          NSLog(@"FIRAuthCredential error - %@", error.localizedDescription);
                                          NSLog(@"Error code -%ld", (long)error.code);
                                          [[FIRAuth auth].currentUser linkWithCredential:credential
                                                                              completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                                                                  if (error) {
                                                                                      NSLog(@"FIRAuth linking error - %@", error.localizedDescription);
                                                                                      return;
                                                                                  }
                                                                                  NSLog(@"Sucessfully linked accounts");
                                                                                  
                                                                                  //Save to database
                                                                                  //Create a user dictionary
                                                                                  NSDictionary *publicUserDict = @{
                                                                                                                   @"name" : [userDict valueForKey:@"name"],
                                                                                                                @"image" : [userDict valueForKey:@"image"]
                                                                                                                   };
                                                                                  //Update public user
                                                                                  [[[[DataService ds] publicUserReference]child:user.uid] updateChildValues:publicUserDict];
                                                                                  
                                                                                  //Change credential to facebook
                                                                                  //userDict[@"provider"] = credential.provider;
                                                                                  [userDict setValue:credential.provider forKey:@"provider"];
                                                                                  
                                                                                  //Update private user
                                                                                  [[[[DataService ds] userReference]child:user.uid] updateChildValues:userDict];

                                                                              }];
                                      }
                                      return;
                                  }
                                  
                                  NSLog(@"Successfully logged in");
                                  //Create User in Firebase - DELETES NEW VALUES CREATED EVERY LOGIN
                                  //Create a public dictionary of user's values
                                  //Create a user dictionary
                                  
                                  NSDictionary *publicUserDict = @{
                                                                   @"name" : [userDict valueForKey:@"name"],
                                                                   @"image" : [userDict valueForKey:@"image"]
                                                                   };
                                  //Update public user
                                  [[[[DataService ds] publicUserReference]child:user.uid] updateChildValues:publicUserDict];
                                  
                                  //Update private user
                                  [[[[DataService ds] userReference]child:user.uid] updateChildValues:userDict];
                                  
                                  //Save Keychain as current uid
                                  //[self keychainSaveWithUID:user.uid];
                                  
                                  //Present Main VC
                                  //                                  MainVC *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
                                  //                                  [self.navigationController pushViewController:mainVC animated:YES];
                                  }];
}
@end
