//
//  ISTransferWorker.m
//  iShare
//
//  Created by Jin Jin on 12-8-29.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISTransferWorker.h"
#import "ISTransferManager.h"

@interface ISTransferWorker()

@end

@implementation ISTransferWorker

-(id)initWithFromPath:(NSString*)fromPath toPath:(NSString*)toPath{
    self = [super init];
    if (self){
        self.fromPath = fromPath;
        self.toPath = toPath;
    }
    
    return self;
}

-(void)addedToQueueWithDelegate:(id<ISTransferWorkerDelegate>)delegate{
    self.delegate = delegate;
    [self beginTransfer];
}

#pragma mark - need override
-(void)beginTransfer{
    
}

-(void)finishTransfer{
    [self.delegate workerDidFinishedTransfer:self];
}

-(void)failedTransferWithError:(NSError*)error{
    [self.delegate workerDidFailedTransfer:self withError:error];
}

@end
