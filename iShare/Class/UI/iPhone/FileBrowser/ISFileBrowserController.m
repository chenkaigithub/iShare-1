//
//  FileBrowserController.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserController.h"
#import "FileBrowserDataSource.h"
#import "CustomUIComponents.h"

@interface ISFileBrowserController ()

@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) FileBrowserDataSource* dataSource;

@end

@implementation ISFileBrowserController

-(id)initWithFilePath:(NSString*)filePath{
    
    self = [super initWithNibName:@"ISFileBrowserController" bundle:nil];
    
    if (self){
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (filePath == nil || (exists == YES && isDirectory == YES)){
            self.filePath = [self defaultFilePath];
            self.title = @"我的电脑";
        }else{
            self.filePath = filePath;
            self.title = [filePath lastPathComponent];
        }
        
        self.tabBarItem.image = [UIImage imageNamed:@"ic_tab_profile"];
        self.tabBarItem.title = self.title;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* actionButton = [CustomUIComponents customBarButtonWithTitle:NSLocalizedString(@"btn_title_operate", nil) target:self action:@selector(actionButtonIsClicked:)];
    
    self.navigationItem.rightBarButtonItem = actionButton;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    FileBrowserDataSource* dataSource = [[FileBrowserDataSource alloc] initWithFilePath:self.filePath];
    self.dataSource = dataSource;
    self.tableView.dataSource = dataSource;
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(NSString*)defaultFilePath{
    NSString* defaultFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    DebugLog(@"%@", defaultFilePath);
    return defaultFilePath;
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - button action
-(void)actionButtonIsClicked:(id)sender{
    
}

@end
