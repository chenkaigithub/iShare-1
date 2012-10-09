//
//  JJBTFileSharer.m
//  iShare
//
//  Created by Jin Jin on 12-9-6.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJBTFileSharer.h"
#import "FileOperationWrap.h"

typedef enum {
    PackageTypeStart,
    PackageTypeEnd,
    PackageTypeData
} PackageType;

@interface JJBTFileSharer ()

@property (nonatomic, strong) GKSession* session;
@property (nonatomic, copy) NSString* storePath;
@property (nonatomic, assign) CFWriteStreamRef currentWriteStream;

@property (nonatomic, retain) NSOperationQueue* sendingQueue;

@end

@implementation JJBTFileSharer

static NSInteger BufferLength = 4096;//limit is 4k

-(id)init{
    self = [super init];
    if (self){
        self.sendingQueue = [[NSOperationQueue alloc] init];
        self.sendingQueue.maxConcurrentOperationCount = 1;
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
}

-(NSString*)nameOfPair{
    NSArray* peers = [self.session peersWithConnectionState:GKPeerStateConnected];
    return [self.session displayNameForPeer:[peers lastObject]];
}

-(void)setStoreFolder:(NSString*)folderPath{
    if (folderPath.length == 0){
        folderPath = [[FileOperationWrap homePath] stringByAppendingPathComponent:NSLocalizedString(@"title_receivedfrombluetooth", nil)];
    }
    
    self.storePath = folderPath;
}

-(void)cancelSending{
    [self.sendingQueue cancelAllOperations];
}

-(void)endSession{
    [self.sendingQueue cancelAllOperations];
    [self.session disconnectFromAllPeers];
}

-(void)sendFiles:(NSArray*)files{
    _currentTransferingFiles = files;
    
    [self.delegate sharer:self willSendingFiles:files];
    [self.session setDataReceiveHandler:self withContext:NULL];
    
    //tell that will send bunch of files
    
    [files enumerateObjectsUsingBlock:^(NSString* file, NSUInteger idx, BOOL* stop){
        NSInvocationOperation* sendOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(sendFile:) object:file];
        [self.sendingQueue addOperation:sendOperation];
    }];

    
}

-(void)sendFile:(NSString*)file{
    _currentTransferingFile = file;
    [self.delegate sharer:self willStartSendingFile:file];
    //每个数据包之前有2位的长度:
    //00 文件开始传输，后跟文件名
    //11 文件结束传输
    //01 文件内容块，后跟文件名
    NSInteger codeLenth = 2;
//send header
    UInt8 header[BufferLength];
    [self constructPackage:header withType:PackageTypeStart bytes:[file cStringUsingEncoding:NSUTF8StringEncoding] length:[file lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [self sendDataInBuffer:header length:[file lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + codeLenth error:NULL];
//prepare reading stream
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)file, kCFURLPOSIXPathStyle, false);
    CFReadStreamRef myReadStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    CFRelease(fileURL);
    
    //assume it won't fail
    CFReadStreamOpen(myReadStream);
    
    CFIndex numBytesRead;
    
    do {

        UInt8 buf[BufferLength]; // define myReadBufferSize as desired
        buf[0] = 0;
        buf[1] = 1;
        numBytesRead = CFReadStreamRead(myReadStream, buf+codeLenth, sizeof(buf) - codeLenth);
        if( numBytesRead > 0 ) {
            NSError* error;
            if ([self sendDataInBuffer:buf length:numBytesRead+codeLenth error:&error] == NO){
                //error happend
                if (error){
#pragma mark - add error handler code
                    break;
                    CFReadStreamClose(myReadStream);
                    CFRelease(myReadStream);
                    myReadStream = NULL;
                }
            };
        } else if( numBytesRead < 0 ) {
            //error happened
            CFStreamError error = CFReadStreamGetError(myReadStream);
//            reportError(error);
        }
        //wait a little while
        [NSThread sleepForTimeInterval:0.01];
    } while( numBytesRead > 0 );
    CFReadStreamClose(myReadStream);
    CFRelease(myReadStream);
    myReadStream = NULL;
    
//send tail
    UInt8 tail[BufferLength];
    [self constructPackage:tail withType:PackageTypeEnd bytes:[file cStringUsingEncoding:NSUTF8StringEncoding] length:[file lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [self sendDataInBuffer:tail length:[file lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + codeLenth error:NULL];
    
    [self.delegate sharer:self finishedSendingFile:file];
}

-(void)constructPackage:(UInt8*)package withType:(PackageType)type bytes:(const void *)bytes length:(NSUInteger)length{
    
    memset(package, 0, BufferLength);
    
    switch (type) {
        case PackageTypeData:
            package[0] = 0;
            package[1] = 1;
            break;
        case PackageTypeEnd:
            package[0] = 1;
            package[1] = 1;
            break;
        case PackageTypeStart:
            package[0] = 0;
            package[1] = 0;
            break;
        default:
            break;
    }
    
    if (length > 0){
        memcpy(package+2, bytes, length);
    }
}

-(BOOL)sendDataInBuffer:(UInt8*)buffer length:(NSUInteger)length error:(NSError **)error;{
    NSData* data = [NSData dataWithBytes:buffer length:length];
    return [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:error];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    //data receiveing handler
    //check package head
    NSUInteger length = [data length];
    UInt8 *buff = (UInt8*)[data bytes]; 
    
    if (buff[0] == 0 && buff[1] == 0){
        //start
        NSString* orignalFilename = [NSString stringWithCString:(const void*)(buff+2) encoding:NSUTF8StringEncoding];
        _currentTransferingFile = orignalFilename;
    
        [self.delegate sharer:self willStartReceivingFile:orignalFilename];
        NSString* destFilename = [FileOperationWrap validFilePathForFilename:[orignalFilename lastPathComponent] atPath:self.storePath];
        CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)destFilename, kCFURLPOSIXPathStyle, false);
        self.currentWriteStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, fileURL);
        CFRelease(fileURL);
        //create a write stream
    }else if (buff[0] == 1 && buff[1] == 1){
        //end
        //close the write stream
        CFWriteStreamClose(self.currentWriteStream);
        CFRelease(self.currentWriteStream);
        self.currentWriteStream = NULL;
        NSString* orignalFilename = [NSString stringWithCString:(const void*)(buff+2) encoding:NSUTF8StringEncoding];

        _currentTransferingFile = nil;
        [self.delegate sharer:self finishedReceivingFile:orignalFilename savingPath:nil];
        
    }else if (buff[0] == 0 && buff[1] == 1){
        //data
        //write data
        if (CFWriteStreamWrite(self.currentWriteStream, buff + 2, length - 2) == -1){
            //error happened
        };
    }
}

#pragma mark - gk session delegate
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    if ([[self.session peersWithConnectionState:GKPeerStateConnected] count] == 0){
        [self.delegate sharerIsDisconnectedWithPair:self];
    }
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error{
    [self.delegate sharerIsDisconnectedWithPair:self];
}

@end
