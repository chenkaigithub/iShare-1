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

typedef enum {
    JJAudioPlayerModeSequence = 1,
    JJAudioPlayerModeSequenceLoop = 2,
    JJAudioPlayerModeShuffle = 4,
    JJAudioPlayerModeRepeatOne = 8
}JJAudioPlayerMode;

@interface JJAudioPlayerManager : NSObject<AVAudioSessionDelegate>

@property (nonatomic, assign) JJAudioPlayerMode playerMode;

+(JJAudioPlayerManager*)sharedManager;

+(AVAudioPlayer*)currentPlayer;
+(NSInteger)currentIndex;

-(AVAudioPlayer*)playerWithMusicItems:(NSArray*)musicItems Index:(NSInteger)index;
-(AVAudioPlayer*)playerForNextMusic;
-(AVAudioPlayer*)playerForPreviousMusic;
-(BOOL)canGoNextTrack;
-(BOOL)canGoPreviouseTrack;

@end
