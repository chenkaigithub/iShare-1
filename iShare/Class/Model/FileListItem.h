//
//  FileListItem.h
//  iShare
//
//  Created by Jin Jin on 12-8-4.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

typedef enum {
    FileListItemTypeFilePath,
    FileListItemTypeActionMenu
} FileListItemType;

@interface FileListItem : NSObject<QLPreviewItem>

@property (nonatomic, assign) FileListItemType type;
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, strong) NSDictionary* attributes;

@end
