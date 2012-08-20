
//
//  JJAudioPlayerManager.m
//  iShare
//
//  Created by Jin Jin on 12-8-19.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJAudioPlayerManager.h"

@interface JJAudioPlayerManager()

@property (nonatomic, strong) AVAudioPlayer* currentPlayer;

@property (nonatomic, strong) NSArray* musicURLs;
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

-(AVAudioPlayer*)playerWithMusicURLs:(NSArray*)musicURLs Index:(NSInteger)index{
    self.musicURLs = musicURLs;
    self.currentIndex = index;
    
    return [self playerWithContentOfURL:[self.musicURLs objectAtIndex:index] error:NULL];
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

#pragma mark - play music
-(void)playMusic{
    [self.currentPlayer play];
}

-(void)stopMusic{
    [self.currentPlayer stop];
}

-(void)playNext{
    if (self.currentIndex+1 >= [self.musicURLs count]){
        return;
    }
    
    self.currentIndex++;
    [self.currentPlayer stop];
    self.currentPlayer = [[self class] playerWithContentOfURL:[self.musicURLs objectAtIndex:self.currentIndex] error:NULL];
    
    [self.currentPlayer play];
}

-(void)playPrevious{
    if (self.currentIndex-1 < 0){
        return;
    }
    
    self.currentIndex--;
    [self.currentPlayer stop];
    self.currentPlayer = [[self class] playerWithContentOfURL:[self.musicURLs objectAtIndex:self.currentIndex] error:NULL];
    
    [self.currentPlayer play];
}

@end
