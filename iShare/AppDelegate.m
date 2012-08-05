//
//  AppDelegate.m
//  iShare
//
//  Created by Jin Jin on 12-7-31.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "AppDelegate.h"

#import "MainTabBarController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeUI];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)customizeUI{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_title_bar"] forBarMetrics:UIBarMetricsDefault];
}

@end
