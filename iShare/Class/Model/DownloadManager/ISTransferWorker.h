//
//  ISTransferWorker.h
//  iShare
//
//  Created by Jin Jin on 12-8-29.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISTransferManager, ISTransferWorker;

@protocol ISTransferWorkerDelegate <NSObject>

-(void)workerDidFinishedTransfer:(ISTransferWorker*)worker;
-(void)workerDidFailedTransfer:(ISTransferWorker*)worker withError:(NSError*)error;

@end

@interface ISTransferWorker : NSObject

@property (nonatomic, copy) NSString* fromPath;
@property (nonatomic, copy) NSString* toPath;

@property (nonatomic, weak) id<ISTransferWorkerDelegate> delegate;

-(id)initWithFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
-(void)addedToQueueWithDelegate:(id<ISTransferWorkerDelegate>)delegate;

//need override
-(void)beginTransfer;
-(void)finishTransfer;
-(void)failedTransferWithError:(NSError*)error;

@end
