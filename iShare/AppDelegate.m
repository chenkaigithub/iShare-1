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
#import "ISUserPreferenceDefine.h"
#import "JJHTTPSerivce.h"
#import <DropboxSDK/DropboxSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CustomUIComponents customizeUI];
    [FileOperationWrap clearTempFolder];
    
    //dropbox init
    NSString* appKey = @"u4pqeo7i6pfxnx1";
    NSString* appSecret = @"1i6qgm4rywi0hrn";
    NSString *root = kDBRootDropbox;
    DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];
    //http server init
    JJHTTPSerivce* service = [JJHTTPSerivce sharedSerivce];
    [service setPort:[ISUserPreferenceDefine httpSharePort]];
    service.authEnabled = [ISUserPreferenceDefine HttpShareAuthEnabled];
    [service setUsername:[ISUserPreferenceDefine httpShareUsername]];
    [service setPassword:[ISUserPreferenceDefine httpSharePassword]];
    
    if ([ISUserPreferenceDefine shouldAutoStartHTTPShare]){
        [[JJHTTPSerivce sharedSerivce] startService];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([[DBSession sharedSession] handleOpenURL:url]) {
//		if ([[DBSession sharedSession] isLinked]) {
//			[navigationController pushViewController:rootViewController.photoViewController animated:YES];
//		}
		return YES;
	}
	
	return NO;
}

//for music player
- (void)remoteControlReceivedWithEvent:(UIEvent *)event

{
    
    //NSLog(@"UIEventTypeRemoteControl: %d - %d", event.type, event.subtype);
    
    if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
        
        //NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
        
        AVAudioPlayer* player = [JJAudioPlayerManager currentPlayer];
        if (player.isPlaying){
            [player stop];
        }else{
            [player play];
        }
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPlay) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPlay");
        
        AVAudioPlayer* player = [JJAudioPlayerManager currentPlayer];
        [player play];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPause) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPause");
        
        AVAudioPlayer* player = [JJAudioPlayerManager currentPlayer];
        [player stop];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlStop) {
        
        //NSLog(@"UIEventSubtypeRemoteControlStop");
        
        AVAudioPlayer* player = [JJAudioPlayerManager currentPlayer];
        [player stop];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
        
        //NSLog(@"UIEventSubtypeRemoteControlNextTrack");
        
        AVAudioPlayer* player = [[JJAudioPlayerManager sharedManager] playerForNextMusic];
        [player play];
        
    }
    
    if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
        
        //NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
        
        AVAudioPlayer* player = [[JJAudioPlayerManager sharedManager] playerForPreviousMusic];
        [player play];
        
    }
    
}



@end
