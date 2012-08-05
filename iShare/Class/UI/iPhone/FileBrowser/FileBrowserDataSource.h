//
//  FileBrowserDataSource.h
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileBrowserDataSource : NSObject <UITableViewDataSource>

-(id)initWithFilePath:(NSString*)filePath;

@end
