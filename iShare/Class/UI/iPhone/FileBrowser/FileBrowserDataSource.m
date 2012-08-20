//
//  FileBrowserDataSource.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FileBrowserDataSource.h"
#import "FileListItem.h"
#import "ISFileBrowserCell.h"
#import "ISFileBrowserMenuCell.h"
#import "ISFileBrowserCellInterface.h"

//comparators
static NSComparator SortBlockByType = ^(FileListItem* item1, FileListItem* item2) {
    if ([[item1.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        return NSOrderedAscending;
    }
    
    return [[item1.filePath pathExtension] compare:[item2.filePath pathExtension]];
};

static NSComparator SortBlockByName = ^(FileListItem* item1, FileListItem* item2) {
    return [[item1.filePath lowercaseString] compare:[item2.filePath lowercaseString]];
};

static NSComparator SortBlockByDate = ^(FileListItem* item1, FileListItem* item2) {
    
    return [[item2.attributes fileModificationDate] compare:[item1.attributes fileModificationDate]];
};

@interface FileBrowserDataSource (){
    BOOL _menuShowed;
}

@property (nonatomic, strong) NSMutableArray* fileListItems;
@property (nonatomic, strong) NSMutableArray* allFileItems;
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, assign) FileBrowserDataSourceOrder orderType;
@property (nonatomic, copy) NSString* searchKeyword;
//only one menu at one time
@property (nonatomic, strong) FileListItem* menuItem;

@end

@implementation FileBrowserDataSource

-(id)initWithFilePath:(NSString*)filePath{
    self = [super init];
    if (self){
        self.filePath = filePath;
        self.orderType = FileBrowserDataSourceOrderFileName;
        self.searchKeyword = @"";
        self.menuItem = [[FileListItem alloc] init];
        self.menuItem.filePath = nil;
        self.menuItem.type = FileListItemTypeActionMenu;
        self.removeIndex = NSNotFound;
        self.addIndex = NSNotFound;
        [self refresh];
    }
    
    return self;
}

-(FileListItem*)objectAtIndexPath:(NSIndexPath*)indexPath{
    return [self.fileListItems objectAtIndex:indexPath.row];
}

-(NSIndexPath*)indexPathOfObject:(FileListItem*)item{
    return [NSIndexPath indexPathForRow:[self.fileListItems indexOfObject:item] inSection:0];
}

-(void)refresh{
    NSArray* fileItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.filePath error:NULL];
    NSMutableArray* allItems = [NSMutableArray array];
    [fileItems enumerateObjectsUsingBlock:^(NSString* filename, NSUInteger idx, BOOL* stop){
        FileListItem* item = [[FileListItem alloc] init];
        item.filePath = [self.filePath stringByAppendingPathComponent:filename];
        item.type = FileListItemTypeFilePath;
        [allItems addObject:item];
    }];
    
    self.allFileItems = allItems;
    
    [self getFilteredItems];
    [self sortListByOrder:self.orderType];
}

-(void)hideMenu{
    self.addIndex = NSNotFound;
    self.removeIndex = [self.fileListItems indexOfObject:self.menuItem];
    [self.fileListItems removeObject:self.menuItem];
    self.menuIsShown = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILEBROWSER_MENUGONE object:self];
}

-(void)removeFileItem:(FileListItem*)item{
    [self.fileListItems removeObject:item];
    [self.allFileItems removeObject:item];
}

-(NSIndexPath*)menuIndex{
    return [self indexPathOfObject:self.menuItem];
}

#pragma mark - filter
-(void)getFilteredItems{
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(FileListItem* fileItem, NSDictionary* bindings){
        if (self.searchKeyword.length == 0){
            return YES;
        }else{
            NSString *filename = [[fileItem.filePath lastPathComponent] lowercaseString];
            NSRange range = [filename rangeOfString:[self.searchKeyword lowercaseString]];
            return range.length != 0;
        }
    }];
    
    self.fileListItems = [NSMutableArray arrayWithArray:[self.allFileItems filteredArrayUsingPredicate:predicate]];
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileListItems count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* ActionMenuCellIdentifier = @"ISFileBrowserMenuCell";
    static NSString* FileItemCellIdentifier = @"ISFileBrowserCell";
    
    FileListItem* item = [self.fileListItems objectAtIndex:indexPath.row];
    
    UITableViewCell<ISFileBrowserCellInterface>* cell = nil;
    
    switch (item.type) {
        case FileListItemTypeFilePath:
            cell = [tableView dequeueReusableCellWithIdentifier:FileItemCellIdentifier];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:FileItemCellIdentifier owner:nil options:nil] objectAtIndex:0];
                UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
                rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
                UISwipeGestureRecognizer* leftSwipte = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
                leftSwipte.direction = UISwipeGestureRecognizerDirectionLeft;
                [cell addGestureRecognizer:rightSwipe];
                [cell addGestureRecognizer:leftSwipte];
            }
            break;
        case FileListItemTypeActionMenu:
            cell = [tableView dequeueReusableCellWithIdentifier:ActionMenuCellIdentifier];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:ActionMenuCellIdentifier owner:nil options:nil] objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                ((ISFileBrowserMenuCell*)cell).dataSource = self;
            }
            break;
        default:
            break;
    }
    
    [cell configCell:item];
    
    return cell;
}


#pragma mark - order file items
-(void)sortListByOrder:(FileBrowserDataSourceOrder)order{
    switch (order) {
        case FileBrowserDataSourceOrderFileDate:
            [self.fileListItems sortUsingComparator:SortBlockByDate];
            break;
        case FileBrowserDataSourceOrderFileName:
            [self.fileListItems sortUsingComparator:SortBlockByName];
            break;
        case FileBrowserDataSourceOrderFileType:
            [self.fileListItems sortUsingComparator:SortBlockByType];
            break;
        default:
            break;
    }
    self.orderType = order;
}

#pragma mark - search
-(void)setFilterKeyword:(NSString *)keyword{
    self.searchKeyword = keyword;
    [self getFilteredItems];
}

#pragma mark - swipe gesture action
-(void)swipeGestureAction:(UISwipeGestureRecognizer*)swipeGesture{
    
    ISFileBrowserCell* cell = (ISFileBrowserCell*)swipeGesture.view;
    if (cell.editing){
        return;
    }
    FileListItem* item = [cell cellItem];
    
    self.removeIndex = [self.fileListItems indexOfObject:self.menuItem];
    [self.fileListItems removeObject:self.menuItem];
    
    self.menuItem.filePath = item.filePath;
    self.addIndex = [self.fileListItems indexOfObject:item]+1;
    [self.fileListItems insertObject:self.menuItem atIndex:self.addIndex];
    
    self.menuIsShown = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILEBROWSER_MENUSHOWN object:self];
}

@end
