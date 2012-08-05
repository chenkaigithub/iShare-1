//
//  FileBrowserDataSource.h
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileListItem.h"
#import "FileBrowserNotifications.h"

typedef enum {
    FileBrowserDataSourceOrderFileName,
    FileBrowserDataSourceOrderFileDate,
    FileBrowserDataSourceOrderFileType
} FileBrowserDataSourceOrder;

@interface FileBrowserDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) NSInteger removeIndex;
@property (nonatomic, assign) NSInteger addIndex;
@property (nonatomic, assign) BOOL menuIsShown;

-(id)initWithFilePath:(NSString*)filePath;
-(void)refresh;
-(void)sortListByOrder:(FileBrowserDataSourceOrder)order;
-(void)hideMenu;

-(FileListItem*)objectAtIndexPath:(NSIndexPath*)indexPath;

-(void)setFilterKeyword:(NSString*)keyword;

@end
