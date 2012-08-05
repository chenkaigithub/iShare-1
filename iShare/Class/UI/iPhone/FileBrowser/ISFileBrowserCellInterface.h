//
//  ISFileBrowserCellInterface.h
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileListItem;

@protocol ISFileBrowserCellInterface <NSObject>

-(FileListItem*)cellItem;
-(void)configCell:(FileListItem*)item;

@end
