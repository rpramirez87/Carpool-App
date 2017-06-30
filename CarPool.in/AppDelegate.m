//
//  AppDelegate.m
//  CarPool.in
//
//  Created by Ron Ramirez on 4/27/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "RequestRideViewController.h"
#import "PostRideViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import UserNotifications;


@import Firebase;
@import FirebaseMessaging;
@interface AppDelegate () <FIRMessagingDelegate, UNUserNotificationCenterDelegate>
@end

NSString *const kGCMMessageIDKey = @"gcm.message_id";
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation AppDelegate

#pragma mark - App Delegate Methods


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Register for remote notifications
    //Register Remote Settings
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
//        UIUserNotificationType allNotificationTypes =
//        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//        
//        
//        
//        UIUserNotificationSettings *settings =
//        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    } else {
//        // Support iOS 10 or later
//    }
//    
//    //self register
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [self registerForRemoteNotification];
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    //Firebase Configure
    [FIRApp configure];
    
    //Google Sign in
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    
    //Reset Google Sign in
    [[GIDSignIn sharedInstance] signOut];
    
    //Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    NSLog(@"Shortcut Items - %@",[UIApplication sharedApplication].shortcutItems);
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    NSLog(@"Shorcut Item - %@", shortcutItem.localizedTitle);
    
    if ([shortcutItem.localizedTitle isEqualToString:@"Request a Ride"]) {
        UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RequestRideViewController *requestVC = [storyboard instantiateViewControllerWithIdentifier:@"requestVC"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:requestVC];
        [rootViewController.visibleViewController presentViewController:navigationController animated:YES completion:nil];
    }else if ([shortcutItem.localizedTitle isEqualToString:@"Post A Ride"]) {
        UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostRideViewController *postVC = [storyboard instantiateViewControllerWithIdentifier:@"postVC"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postVC];
        [rootViewController.visibleViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application will Terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Google Sign / Facebook Delegate Functions

//Handles both google and facebook sign in
- (BOOL)application:(UIApplication* )app openURL:(NSURL* )url options:(NSDictionary *)options {
    
    NSLog(@"Url = %@",url);
    NSLog(@"Dict = %@",options);
    
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:options [UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]] ||[[FBSDKApplicationDelegate sharedInstance]application:app openURL:url options:options];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication* )application didRegisterUserNotificationSettings:(UIUserNotificationSettings* )notificationSettings {
    [application registerForRemoteNotifications];
    
    //to get the firebase device token
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"Firebase InstanceID token: %@", refreshedToken);
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"Remote Notifications");
    NSString *deviceTokenString = [[[[deviceToken description]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device Token String- %@",deviceTokenString);
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeSandbox];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"Full Message%@", userInfo);
    
    
    //Extract the rideInfo key from userInfo, Display the appropriate VC with information based on the rideInfo key
    UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileVC];
    [rootViewController.visibleViewController presentViewController:navigationController animated:YES completion:nil];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Remote Notification Error %@", error.localizedDescription);
    
}

- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
        [FIRMessaging messaging].remoteMessageDelegate = self;
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

#pragma mark - Firebase Remote Notifications
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}

#pragma mark - Firebase Messaging Delegate Functions
- (void)applicationReceivedRemoteMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Remote Message App Data %@", remoteMessage.appData);
}

#pragma Firebase Messaging 
// [START connect_to_fcm]
- (void)connectToFcm {
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]

@end
