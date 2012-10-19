//
//  JJBTFileSharer.m
//  iShare
//
//  Created by Jin Jin on 12-9-6.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJBTFileSharer.h"
#import "JJBTFileSender.h"
#import "JJBTPhotoSender.h"
#import "FileItem.h"
#import "FileOperationWrap.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define BundleHeadListSeperator @"&&&&"

typedef enum {
    PackageTypeStart,
    PackageTypeEnd,
    PackageTypeData
} PackageType;

@interface JJBTFileSharer (){
    JJBTFileSharerStatus _status;
}

@property (nonatomic, strong) GKSession* session;
@property (nonatomic, readonly) NSString* storePath;
@property (nonatomic, strong) NSOutputStream* writeStream;

@property (nonatomic, retain) NSOperationQueue* sendingQueue;

@end

@implementation JJBTFileSharer

-(id)init{
    self = [super init];
    if (self){
        self.sendingQueue = [[NSOperationQueue alloc] init];
        self.sendingQueue.maxConcurrentOperationCount = 1;
        [self.sendingQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionOld context:nil];
    }
    
    return self;
}

+(id)defaultSharer{
    static dispatch_once_t onceToken;
    static JJBTFileSharer* sharer = nil;
    dispatch_once(&onceToken, ^{
        sharer = [[JJBTFileSharer alloc] init];
    });
    
    return sharer;
}

+(void)setDefaultGKSession:(GKSession*)session{
    JJBTFileSharer* sharer = [self defaultSharer];
    session.delegate = sharer;
    sharer.session = session;
    [sharer.session setDataReceiveHandler:sharer withContext:NULL];
}

-(NSString*)nameOfPair{
    NSArray* peers = [self.session peersWithConnectionState:GKPeerStateConnected];
    return [self.session displayNameForPeer:[peers lastObject]];
}

-(BOOL)isConnected{
    return [self nameOfPair].length > 0;
}

-(NSString*)storePath{
    return [[FileOperationWrap homePath] stringByAppendingPathComponent:NSLocalizedString(@"title_receivedfrombluetooth", nil)];
}

-(void)cancelSending{
    [self.sendingQueue cancelAllOperations];
}

-(void)cancelReceiving{
    
}

-(void)endSession{
    [self.sendingQueue cancelAllOperations];
    [self.session disconnectFromAllPeers];
}

-(void)sendFiles:(NSArray*)files{
    _status = JJBTFileSharerStatusSending;
    
    //send bundle head
    NSMutableArray* filePaths = [NSMutableArray array];
    [files enumerateObjectsUsingBlock:^(FileItem* file, NSUInteger idx, BOOL* stop){
        NSString* filename = [file.filePath lastPathComponent];
        NSString* size = [NSString stringWithFormat:@"%lld", [file.attributes fileSize]];
        [filePaths addObject:@{@"filename" : filename, @"size":size}];
    }];
    [self sendBundleHeadWithType:BTSenderTypeFile list:filePaths];
    
    
    //tell that will send bunch of files
    [files enumerateObjectsUsingBlock:^(FileItem* file, NSUInteger idx, BOOL* stop){
        JJBTFileSender* fileSender = [[JJBTFileSender alloc] init];
        fileSender.delegate = self;
        fileSender.session = self.session;
        fileSender.sendingObj = file.filePath;
        [self.sendingQueue addOperation:fileSender];
    }];
    
}

-(NSArray*)allSenders{
    return [self.sendingQueue operations];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    //data receiveing handler
    //check package head
    DebugLog(@"reveiving data");
    
    NSUInteger length = [data length];
    UInt8 *buff = (UInt8*)[data bytes];

    NSData* contentData = [NSData dataWithBytes:buff+BTBlockHeadSize length:length-BTBlockHeadSize];
    
    switch (buff[0]) {
        case BTTransitionBlockTypeHead:
            [self startReceiving:contentData];
            break;
        case BTTransitionBlockTypeTail:
            [self finishedReceiving:contentData];
            break;
        case BTTransitionBlockTypeBody:
            [self receivedData:contentData];
            break;
        case BTTransitionBlockTypeError:
            [self receivingErrorHappened:contentData];
            break;
        case BTTransitionBlockTypeBundleHead:
            [self receivedBundleHead:contentData];
            break;
        case BTTransitionBlockTypeBundleTail:
            [self receivedBundleTail:contentData];
            break;
        default:
            break;
    }
}

-(void)cancelAllTransitions{
    [self cancelSending];
    [self cancelReceiving];
}

#pragma mark - content receiving handler
-(void)receivedBundleHead:(NSData*)bundleHead{
    NSDictionary* bundleContent = [NSJSONSerialization JSONObjectWithData:bundleHead options:NSJSONReadingAllowFragments error:NULL];
    
    if ([self.delegate respondsToSelector:@selector(sharerDidStartReceiving:headContent:)]){
        [self.delegate sharerDidStartReceiving:self headContent:bundleContent];
    }
}

-(void)receivedBundleTail:(NSData*)bundleTail{
    if ([self.delegate respondsToSelector:@selector(sharerDidEndReceiving:)]){
        [self.delegate sharerDidEndReceiving:self];
    }
}

-(void)startReceiving:(NSData*)head{
    NSDictionary* headContent = [NSJSONSerialization JSONObjectWithData:head options:NSJSONReadingAllowFragments error:NULL];

    BTSenderType type = [[headContent objectForKey:@"type"] intValue];
    NSString* name = [headContent objectForKey:@"name"];
//    long long size = [[headContent objectForKey:@"size"] longLongValue];
    
    switch (type) {
        case BTSenderTypeFile:
            [self startReceivingFile:name];
            break;
        case BTSenderTypePhoto:
            break;
        case BTSenderTypeUnknown:
            break;
        default:
            break;
    }
}

-(void)finishedReceiving:(NSData*)tail{
    [self.writeStream close];
    [self photoReceivingFinished];
}

-(void)receivedData:(NSData*)data{
    dispatch_async(dispatch_get_current_queue(), ^{
        [self.writeStream write:[data bytes] maxLength:[data length]];
    });
}

-(void)receivingErrorHappened:(NSData*)data{
    [self.writeStream close];
}

#pragma mark - receiving file
-(void)startReceivingFile:(NSString*)name{
    NSString* filePath = [FileOperationWrap validFilePathForFilename:name atPath:self.storePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.storePath] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.storePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    self.writeStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [self.writeStream open];
}

#pragma mark - receiving photo
-(void)photoReceivingFinished{
    //save photo to album
}

#pragma mark - send photos
-(void)sendPhotos:(NSArray*)photos{
    //send photots
    [photos enumerateObjectsUsingBlock:^(ALAsset* asset, NSUInteger idx, BOOL* stop){
        JJBTPhotoSender* photoSender = [[JJBTPhotoSender alloc] init];
        photoSender.sendingObj = asset;
    }];
}

#pragma mark - gk session delegate
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    if ([[self.session peersWithConnectionState:GKPeerStateConnected] count] == 0 && state == GKPeerStateDisconnected){
        //cancel all trancision tasks
        [self cancelAllTransitions];
        //tell delegate that i'm failed
        [self.delegate sharerIsDisconnectedWithPair:self];
    }
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error{
    [self cancelAllTransitions];
    [self.delegate sharerIsDisconnectedWithPair:self];
}

#pragma mark - BT sender delegate
-(void)btSenderStartedSending:(JJBTSender*)sender{
    DebugLog(@"staring sending");
}

-(void)btSender:(JJBTSender*)sender finishedBytes:(long long)finishedBytes{
    DebugLog(@"finished bytes %lld", finishedBytes);
    if ([self.delegate respondsToSelector:@selector(sharer:didReceiveBytes:ofFile:)]){
//        self.delegate sharer:self didReceivePersentage:<#(CGFloat)#> ofFile:sender.sending
    }
}

-(void)btSenderFinishedSending:(JJBTSender*)sender{
    DebugLog(@"finished sending sender %@", [sender description]);
    [self updateSharerStatus];
}

-(void)btSenderCancelledSending:(JJBTSender*)sender{
    DebugLog(@"cancelled sending sender %@", [sender description]);
    [self updateSharerStatus];
}

-(void)btSender:(JJBTSender *)sender failedWithError:(NSError*)error{
    DebugLog(@"failed sending sender %@ with error %@", [sender description], [error localizedDescription]);
    [self updateSharerStatus];
}

#pragma mark - status
-(JJBTFileSharerStatus)status{
    return _status;
}

-(void)updateSharerStatus{
    if ([self.sendingQueue operationCount] <= 1){
        _status = JJBTFileSharerStatusStandBy;
    }
}

-(NSInteger)countOfSendingFiles{
    return [self.sendingQueue operationCount];
}

-(NSInteger)countOfReceivingFiles{
    return 0;
}

#pragma mark - key value observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.sendingQueue && [keyPath isEqualToString:@"operationCount"]){
        NSInteger newCount = [self.sendingQueue operationCount];
        NSInteger oldCount = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        if (newCount > 0 && oldCount == 0){
            //start sending
            if ([self.delegate respondsToSelector:@selector(sharerDidStartSending:)]){
                [self.delegate sharerDidStartSending:self];
            }
        }else if (oldCount > 0 && newCount == 0){
            //end sending
            if ([self.delegate respondsToSelector:@selector(sharerDidEndSending:)]){
                [self.delegate sharerDidEndSending:self];
            }
            
            [self sendBundleTailWithType:BTTransitionBlockTypeBundleTail];
        }
    }
}

#pragma mark - send bunch head
-(void)sendBundleHeadWithType:(BTTransitionBlockType)type list:(NSArray*)list{
    
    NSDictionary* headContent = @{@"type" : [NSString stringWithFormat:@"%d", type], @"list":list};
    
    NSData* contentData = [NSJSONSerialization dataWithJSONObject:headContent options:NSJSONReadingAllowFragments error:NULL];
    
    JJBTSender* sender = [[JJBTSender alloc] init];
    
    NSData* sendBlock = [sender blockWithType:BTTransitionBlockTypeBundleHead data:contentData];
    
    [self.session sendDataToAllPeers:sendBlock withDataMode:GKSendDataReliable error:NULL];
}

-(void)sendBundleTailWithType:(BTTransitionBlockType)type{
    JJBTSender* sender = [[JJBTSender alloc] init];
    NSData* sendBlock = [sender blockWithType:BTTransitionBlockTypeBundleTail data:[NSData data]];
    
    [self.session sendDataToAllPeers:sendBlock withDataMode:GKSendDataReliable error:NULL];
}

@end
