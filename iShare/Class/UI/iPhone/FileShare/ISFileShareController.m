//
//  ISFileShareController.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileShareController.h"
#import "ISDropBoxViewController.h"
#import "ISiCloudServiceViewController.h"
#import "ISSkydriveViewController.h"

#define kLocalShareSection 0
#define kCloudServiceSection 1
#define kTransferQueue 2

@interface ISFileShareController ()

@end

@implementation ISFileShareController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"tab_title_share", nil);
        self.tabBarItem.title = NSLocalizedString(@"tab_title_share", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"ic_tab_profile"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case kLocalShareSection:
        {
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:
                    break;
                default:
                    break;
            }
        }
            break;
        case kCloudServiceSection:
            switch (indexPath.row) {
                case 0://iCloud
                {
                    ISiCloudServiceViewController* iCloudController = [[ISiCloudServiceViewController alloc] initWithWorkingPath:@""];
                    [self.navigationController pushViewController:iCloudController animated:YES];
                }
                    break;
                case 1://Dropbox
                {
                    ISDropBoxViewController* dropboxController = [[ISDropBoxViewController alloc] initWithWorkingPath:@"/"];
                    [self.navigationController pushViewController:dropboxController animated:YES];
                }
                    break;
                case 2://Skydrive
                {
                    ISSkydriveViewController* skydriveController = [[ISSkydriveViewController alloc] initWithWorkingPath:@"/me/skydrive"];
                    [self.navigationController pushViewController:skydriveController animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case kTransferQueue:
            switch (indexPath.row) {
                case 0://download
                {
                    
                }
                    break;
                case 1://upload
                {
                    
                }
                    break;
                default:
                    break;
            }
        default:
            break;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NSLocalizedString(@"section_title_localshare", nil);
            break;
        case 1:
            return NSLocalizedString(@"section_title_cloudstorageservice", nil);
            break;
        case 2:
            return NSLocalizedString(@"section_title_transferqueue", nil);
        default:
            return nil;
            break;
    }
}

#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case kLocalShareSection:
            return 2;
            break;
        case kCloudServiceSection:
            return 3;
            break;
        case kTransferQueue:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentitier = @"FileShareTableviewCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentitier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentitier];
    }
    
    switch (indexPath.section) {
        case kLocalShareSection:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"WIFI";
                    break;
                case 1:
                    cell.textLabel.text = @"Bluetooth";
                    break;
                default:
                    break;
            }
        }
            break;
        case kCloudServiceSection:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"iCloud";
                    break;
                case 1:
                    cell.textLabel.text = @"Dropbox";
                    break;
                case 2:
                    cell.textLabel.text = @"Skydrive";
                    break;
                default:
                    break;
            }
            break;
        case kTransferQueue:{
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"cell_title_download", nil);
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"cell_title_upload", nil);
                default:
                    break;
            }
        }
        default:
            break;
    }
    
    return cell;
}

@end
