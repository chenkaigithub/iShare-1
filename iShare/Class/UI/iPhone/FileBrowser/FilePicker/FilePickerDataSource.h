//
//  FilePickerDataSource.h
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FilePickerTypeFile,
    FilePickerTypeDirectory,
} FilePickerType;

@interface FilePickerDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, assign) FilePickerType pickerType;

-(id)initWithFilePath:(NSString*)filePath pickerType:(FilePickerType)type;
-(void)refresh;

-(id)objectAtIndexPath:(NSIndexPath*)indexPath;

@end
