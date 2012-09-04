//
//  ISTransferManager.h
//  iShare
//
//  Created by Jin Jin on 12-8-29.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISTransferWorker.h"

#define NOTIFICATION_DOWNLOADQUEUE_CHANGED @"NOTIFICATION_DOWNLOADQUEUE_CHANGED"
#define NOTIFICATION_UPLOADQUEUE_CHANGED @"NOTIFICATION_UPLOADQUEUE_CHANGED"

@class ISTransferManager;

@protocol ISTransferManagerDelegate <NSObject>

@optional

-(void)queueDidChangeForTransferManager:(ISTransferManager*)manager;

@end

@interface ISTransferManager : NSObject<ISTransferWorkerDelegate>

@property (nonatomic, strong) id<ISTransferWorkerDelegate> delegate;

+(id)sharedManager;

-(void)addToDownloadQueue:(ISTransferWorker*)worker;
-(void)addToUploadQueue:(ISTransferWorker*)worker;

-(NSArray*)downloadQueue;
-(NSArray*)uploadQueue;

@end
