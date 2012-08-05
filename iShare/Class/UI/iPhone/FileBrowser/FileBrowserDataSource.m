//
//  FileBrowserDataSource.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FileBrowserDataSource.h"

@interface FileBrowserDataSource ()

@property (nonatomic, strong) NSMutableArray* fileListItems;

@end

@implementation FileBrowserDataSource

-(id)initWithFilePath:(NSString*)filePath{
    self = [super init];
    if (self){
        self.fileListItems = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL]];
    }
    
    return self;
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileListItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = [[self.fileListItems objectAtIndex:indexPath.row] lastPathComponent];
    
    return cell;
}

@end
