//
//  NSDictionary+FileOperationWrap.m
//  iShare
//
//  Created by Jin Jin on 12-9-25.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "NSDictionary+FileOperationWrap.h"

@implementation NSDictionary (FileOperationWrap)

-(NSString*)normalizedFileSize{
    double size = [self fileSize];
    if (size <= 999){
        return [NSString stringWithFormat:@"%.0fB", size];
    }else if (size > 999 && size <= 999999){
        return [NSString stringWithFormat:@"%.1fKB", size/1000];
    }else if (size > 999999 && size <= 999999999){
        return [NSString stringWithFormat:@"%.2fMB", size/1000000];
    }else{
        return [NSString stringWithFormat:@"%.2fGB", size/1000000000];
    }
}

-(NSString*)shortLocalizedModificationDate{
    NSDate* date = [self fileModificationDate];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [format stringFromDate:date];
}

@end
