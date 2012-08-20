//
//  JJAudioPlayerManager.h
//  iShare
//
//  Created by Jin Jin on 12-8-19.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface JJAudioPlayerManager : NSObject<AVAudioSessionDelegate>

+(JJAudioPlayerManager*)sharedManager;

+(AVAudioPlayer*)currentPlayer;

-(AVAudioPlayer*)playerWithMusicURLs:(NSArray*)musicURLs Index:(NSInteger)index;

-(void)playMusic;
-(void)stopMusic;
-(void)playNext;
-(void)playPrevious;

@end
