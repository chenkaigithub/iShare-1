//
//  JJBTFileSharer.h
//  iShare
//
//  Created by Jin Jin on 12-9-6.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef enum {
    JJBTFileSharerStatusConnected,
    JJBTFileSharerStatusSending,
    JJBTFileSharerStatusReceiving,
    JJBTFileSharerStatusNotConnected
} JJBTFileSharerStatus;

@class JJBTFileSharer;

@protocol JJBTFileSharerDelegate

//配对失败
//-(void)sharerPairFailed:(JJBTFileSharer*)sharer withError:(NSError*)error;
//配对成功
//-(void)sharerPairSucceeded:(JJBTFileSharer*)sharer;
//文件发送状态
-(void)sharer:(JJBTFileSharer*)sharer willSendingFiles:(NSArray*)files;
-(void)sharer:(JJBTFileSharer*)sharer willReceiveFiles:(NSArray*)files;
-(void)sharer:(JJBTFileSharer*)sharer willStartSendingFile:(NSString*)filePath;
-(void)sharer:(JJBTFileSharer*)sharer willStartReceivingFile:(NSString*)filePath;
-(void)sharer:(JJBTFileSharer*)sharer didSendPersentage:(CGFloat)persentage ofFile:(NSString*)filePath;
-(void)sharer:(JJBTFileSharer *)sharer didReceivePersentage:(CGFloat)persentage ofFile:(NSString *)filePath;
-(void)sharer:(JJBTFileSharer*)sharer finishedSendingFile:(NSString*)filePath;
-(void)sharer:(JJBTFileSharer*)sharer finishedReceivingFile:(NSString*)filePath savingPath:(NSString*)savingPath;

-(void)sharer:(JJBTFileSharer*)sharer currentTransitionFailed:(NSError*)error;
-(void)sharerTransitionCancelled:(JJBTFileSharer*)sharer;

-(void)sharerIsDisconnectedWithPair:(JJBTFileSharer*)sharer;

@end

@interface JJBTFileSharer : NSObject<GKSessionDelegate>

@property (nonatomic, weak) id<JJBTFileSharerDelegate> delegate;
@property (nonatomic, readonly) JJBTFileSharerStatus status;
@property (nonatomic, readonly) NSArray* currentTransferingFiles;
@property (nonatomic, readonly) NSString* currentTransferingFile;

+(id)defaultSharer;
+(void)setDefaultGKSession:(GKSession*)session;

-(void)setStoreFolder:(NSString*)folderPath;
-(BOOL)isConnected;
-(NSString*)nameOfPair;
//双方握手确定协议 -- not necessary
//-(void)shakingHands;
-(void)sendFiles:(NSArray*)files;

-(void)cancelSending;
-(void)endSession;
//


@end
