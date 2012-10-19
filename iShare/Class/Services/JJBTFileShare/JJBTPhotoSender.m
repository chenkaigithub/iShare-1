//
//  JJBTPhotoSender.m
//  iShare
//
//  Created by Jin Jin on 12-10-13.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "JJBTPhotoSender.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation JJBTPhotoSender

-(long long)sizeOfObject{
    ALAsset* asset = self.sendingObj;
    id URLs = [asset valueForProperty:ALAssetPropertyURLs];
    DebugLog(@"%@", URLs);
    
    return 0;
}

-(NSInputStream*)readStream{
    ALAsset* asset = self.sendingObj;
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    UIImage* image = [UIImage imageWithCGImage:[rep fullResolutionImage]];
    NSData* pngData = UIImagePNGRepresentation(image);
    
    return [NSInputStream inputStreamWithData:pngData];
}

-(BTSenderType)type{
    return BTSenderTypePhoto;
}

@end
