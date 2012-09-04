//
//  ISTransferManager.m
//  iShare
//
//  Created by Jin Jin on 12-8-29.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISTransferManager.h"

@interface ISTransferManager ()

@property (nonatomic, strong) NSMutableArray* internalDownloadQueue;
@property (nonatomic, strong) NSMutableArray* internalUploadQueue;

@end

@implementation ISTransferManager

+(id)sharedManager{
    static ISTransferManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ISTransferManager alloc] init];
    });
    
    return manager;
}

-(id)init{
    self = [super init];
    if (self){
        self.internalDownloadQueue = [NSMutableArray array];
        self.internalUploadQueue = [NSMutableArray array];
    }
    
    return self;
}

-(void)addToDownloadQueue:(ISTransferWorker *)worker{
    [self.internalDownloadQueue addObject:worker];
    [self downloadQueueChanged];
}

-(void)addToUploadQueue:(ISTransferWorker *)worker{
    [self.internalUploadQueue addObject:worker];
    [self uploadQueueChanged];
}

-(NSArray*)downloadQueue{
    return [NSArray arrayWithArray:self.internalDownloadQueue];
}

-(NSArray*)uploadQueue{
    return [NSArray arrayWithArray:self.internalUploadQueue];
}

#pragma mark - queue triger
-(void)uploadQueueChanged{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOADQUEUE_CHANGED object:nil];
}

-(void)downloadQueueChanged{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOADQUEUE_CHANGED object:nil];
}

#pragma ISTransferWorkerDelegate

//-(void)

@end
