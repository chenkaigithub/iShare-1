//
//  FilePickerContentController.m
//  iShare
//
//  Created by Jin Jin on 12-8-12.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FilePickerContentController.h"
#import "FileOperationWrap.h"
#import "FileListItem.h"

@interface FilePickerContentController ()

@property (nonatomic, strong) FilePickerDataSource* dataSource;
@property (nonatomic, assign) FilePickerType type;

@end

@implementation FilePickerContentController

-(id)initWithFilePath:(NSString*)filePath pickerType:(FilePickerType)type{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    if (self){
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (filePath == nil || exists == NO || (exists == YES && isDirectory == NO)){
            self.filePath = [FileOperationWrap homePath];
            self.title = NSLocalizedString(@"tab_title_myfiles", nil);
        }else{
            self.filePath = filePath;
            self.title = [filePath lastPathComponent];
        }
        self.type = type;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch (self.type) {
        case FilePickerTypeDirectory:
            self.tableView.allowsMultipleSelection = NO;
            break;
        case FilePickerTypeFile:
            self.tableView.allowsMultipleSelectionDuringEditing = YES;
            self.tableView.editing = YES;
            break;
        default:
            break;
    }

    self.doneButton.title = NSLocalizedString(@"btn_title_confirm", nil);
    [self.doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.cancelButton.title = NSLocalizedString(@"btn_title_cancel", nil);
    
    self.navigationItem.rightBarButtonItems = @[self.doneButton, self.cancelButton];
    
    self.dataSource = [[FilePickerDataSource alloc] initWithFilePath:self.filePath pickerType:self.type];
    [self.dataSource refresh];
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSArray*)selectedFilePath{
    NSArray* selectedIndexs = [self.tableView indexPathsForSelectedRows];
    return [self.dataSource objectsForIndexPaths:selectedIndexs];
}

#pragma mark - table vie delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileListItem* item = [self.dataSource objectAtIndexPath:indexPath];
    if ([[item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        FilePickerContentController* controller = [[FilePickerContentController alloc] initWithFilePath:item.filePath pickerType:self.type];
        [self.navigationController pushViewController:controller animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - button action
-(void)doneButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PICKERCONTENT_DONE object:nil];
}

-(void)cancelButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PICKERCONTENT_CANCEL object:nil];
}

@end
