//
//  SignUpViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/27/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "SignUpViewController.h"
#import "FCAlertView.h"

@import FirebaseAuth;
@import FirebaseDatabase;


@interface SignUpViewController () <GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

//Root Reference
@property (strong, nonatomic) FIRDatabaseReference *rootReference;

@end

@implementation SignUpViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Firebase Reference
    self.rootReference = [[FIRDatabase database] reference];
    
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
                                      
                                      [[[self.rootReference child:@"publicUsers"] child:user.uid] updateChildValues:publicUserDict];
                                      
                                      //Create a user dictionary
                                      NSDictionary *userDict = @{
                                                                 @"name" : fullName,
                                                                 @"image" : stringURL,
                                                                 @"email": email,
                                                                 @"provider" : credential.provider
                                                                 };
                                      
                                      [[[self.rootReference child:@"users"] child:user.uid] updateChildValues:userDict];
                                      
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
            NSLog(@"%@", user.uid);
            
            //Create email user in Firebase private database
            //            [[[self.rootReference child:@"users"] child:user.uid] setValue:@{@"name" : self.nameTextField.text, @"email": email,@"provider":@"email"}];
            //
            //            //Create email user in Firebase public database
            //            [[[self.rootReference child:@"publicUsers"] child:user.uid] setValue:@{@"name" : self.nameTextField.text}];
            
            NSLog(@"Successfully created user");
            
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


@end
