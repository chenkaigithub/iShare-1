
//
//  JJAudioPlayerManager.m
//  iShare
//
//  Created by Jin Jin on 12-8-19.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJAudioPlayerManager.h"
#import "MDAudioFile.h"

@interface JJAudioPlayerManager()

@property (nonatomic, strong) AVAudioPlayer* currentPlayer;

@property (nonatomic, strong) NSArray* musicItems;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation JJAudioPlayerManager

+(void)initialize{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] canBecomeFirstResponder];
}

+(JJAudioPlayerManager*)sharedManager{
    static dispatch_once_t onceToken;
    static JJAudioPlayerManager* _sharedManager;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

+(AVAudioPlayer*)currentPlayer{
    return [self sharedManager].currentPlayer;
}

+(NSInteger)currentIndex{
    return [self sharedManager].currentIndex;
}

-(id)init{
    self = [super init];
    if (self){
        self.playerMode = JJAudioPlayerModeSequence;
    }
    
    return self;
}

-(AVAudioPlayer*)playerWithMusicItems:(NSArray*)musicItems Index:(NSInteger)index{
    self.musicItems = musicItems;
    self.currentIndex = index;
    
    MDAudioFile* musicItem = [self.musicItems objectAtIndex:index];
    
    return [self playerWithContentOfURL:musicItem.filePath error:NULL];
}

-(AVAudioPlayer*)playerWithContentOfURL:(NSURL*)URL error:(NSError**)error{
    
    AVAudioPlayer* player = self.currentPlayer;
    
    if ([[player.url absoluteString] isEqualToString:[URL absoluteString]]){
        return player;
    }
    
    [player stop];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:error];
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    self.currentPlayer = player;
    
    if (sessionError){
        NSLog(@"session error is %@", [sessionError localizedDescription]);
    }
    
    return player;
}

#pragma mark -

-(AVAudioPlayer*)playerForNextMusic{
    if (self.currentIndex+1 >= [self.musicItems count]){
        return nil;
    }
    
    NSUInteger newIndex = 0;
	
    if (self.playerMode & JJAudioPlayerModeShuffle){
        newIndex = rand() % [self.musicItems count];
    }else if (self.playerMode & JJAudioPlayerModeRepeatOne){
        newIndex = self.currentIndex;
    }else if (self.playerMode & JJAudioPlayerModeSequence){
        newIndex = (self.currentIndex + 1)>=[self.musicItems count]?self.currentIndex:self.currentIndex+1;
    }else if (self.playerMode & JJAudioPlayerModeSequenceLoop){
        newIndex = (self.currentIndex + 1)>=[self.musicItems count]?0:self.currentIndex+1;
    }
	
    self.currentIndex = newIndex;
    
    [self.currentPlayer stop];
    self.currentPlayer = [[self class] playerWithContentOfURL:[self.musicItems objectAtIndex:self.currentIndex] error:NULL];
    
    return self.currentPlayer;
}

-(AVAudioPlayer*)playerForPreviousMusic{
    if (self.currentIndex-1 < 0){
        return nil;
    }
    
    NSUInteger newIndex = 0;
	
    if (self.playerMode & JJAudioPlayerModeShuffle){
        newIndex = rand() % [self.musicItems count];
    }else if (self.playerMode & JJAudioPlayerModeRepeatOne){
        newIndex = self.currentIndex;
    }else if (self.playerMode & JJAudioPlayerModeSequence){
        newIndex = (self.currentIndex - 1)<0?self.currentIndex:self.currentIndex-1;
    }else if (self.playerMode & JJAudioPlayerModeSequenceLoop){
        newIndex = (self.currentIndex - 1)<0?0:self.currentIndex-1;
    }
    
    self.currentIndex = newIndex;
    [self.currentPlayer stop];
    self.currentPlayer = [[self class] playerWithContentOfURL:[self.musicItems objectAtIndex:self.currentIndex] error:NULL];
    
    return self.currentPlayer;
}

-(BOOL)canGoNextTrack{
    return !(self.currentIndex + 1 == [self.musicItems count]);
}

-(BOOL)canGoPreviouseTrack{
    return !(self.currentIndex == 0);
}

#pragma mark - avaudioplayer delegate
//-(void)

@end
