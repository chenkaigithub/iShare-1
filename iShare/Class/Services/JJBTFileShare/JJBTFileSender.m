//
//  JJBTFileSender.m
//  iShare
//
//  Created by Jin Jin on 12-10-13.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJBTFileSender.h"

@implementation JJBTFileSender

-(NSInputStream*)readStream{
    return [NSInputStream inputStreamWithFileAtPath:self.sendingObj];
}

-(long long)sizeOfObject{
    NSString* filePath = self.sendingObj;
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:filePath error:NULL];
    
    return [attributes fileSize];
}

-(BTSenderType)type{
    return BTSenderTypeFile;
}

-(NSString*)name{
    return [self.sendingObj lastPathComponent];
}



@end
