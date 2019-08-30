//
//  AppDelegate.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "TSSDeviceModelsDataController.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:35.0/255.0 green:39.0/255.0 blue:42.0/255.0 alpha:1.0];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    application.statusBarStyle = UIStatusBarStyleLightContent;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //delay for 2 secocnds to display the credits..
    [NSThread sleepForTimeInterval:3];
    
    //load the data onn startup..
    [[TSSDeviceModelsDataController sharedInstance] loadDevices:nil];
    return YES;
}

@end
