//
//  AppDelegate.m
//  iShare
//
//  Created by Jin Jin on 12-7-31.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "CustomUIComponents.h"
#import "FileOperationWrap.h"
#import "JJAudioPlayerManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CustomUIComponents customizeUI];
    [FileOperationWrap clearTempFolder];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event

{
    JJAudioPlayerManager* audioManager = [JJAudioPlayerManager sharedManager];
    
    //NSLog(@"UIEventTypeRemoteControl: %d - %d", event.type, event.subtype);
    
    if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        
        //NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
        
        [audioManager playMusic];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPlay");
        
        [audioManager playMusic];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPause) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPause");
        
        [audioManager stopMusic];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlStop) {
        
        //NSLog(@"UIEventSubtypeRemoteControlStop");
        
        [audioManager stopMusic];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
        
        //NSLog(@"UIEventSubtypeRemoteControlNextTrack");
        
        [audioManager playNext];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
        
        [audioManager playPrevious];
        
    }
    
}



@end
