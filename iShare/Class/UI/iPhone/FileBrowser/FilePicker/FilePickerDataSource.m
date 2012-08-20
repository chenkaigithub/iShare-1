//
//  FilePickerDataSource.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FilePickerDataSource.h"
#import "ISFileBrowserCell.h"
#import "FileListItem.h"

@interface FilePickerDataSource()

@property (nonatomic, copy) NSString* filePath;

@property (nonatomic, retain) NSArray* fileItems;

@end

@implementation FilePickerDataSource

-(id)initWithFilePath:(NSString*)filePath pickerType:(FilePickerType)type{
    self = [super init];
    
    if (self){
        self.filePath = filePath;
        self.pickerType = type;
    }
    
    return self;
}

-(void)refresh{
    NSArray* fileItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.filePath error:NULL];
    NSMutableArray* allItems = [NSMutableArray array];
    [fileItems enumerateObjectsUsingBlock:^(NSString* filename, NSUInteger idx, BOOL* stop){
        FileListItem* item = [[FileListItem alloc] init];
        item.filePath = [self.filePath stringByAppendingPathComponent:filename];
        item.type = FileListItemTypeFilePath;
        
        if (!(self.pickerType == FilePickerTypeDirectory && [[item.attributes fileType] isEqualToString:NSFileTypeDirectory] == NO)){
            [allItems addObject:item];
        }
    }];
    
    self.fileItems = allItems;

}

-(id)objectAtIndexPath:(NSIndexPath*)indexPath{
    return [self.fileItems objectAtIndex:indexPath.row];
}

#pragma mark - data source methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"FilePickerCell";
    ISFileBrowserCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ISFileBrowserCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [cell configCell:[self.fileItems objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
