//
//  ISFileShareController.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileShareController.h"
#import "ISBluetoothViewController.h"
#import "ISWifiViewController.h"
#import "ISDropBoxViewController.h"
#import "ISiCloudServiceViewController.h"
#import "ISSkydriveViewController.h"
#import "JJHTTPSerivce.h"
#import "BWStatusBarOverlay.h"
#import "CustomUIComponents.h"
#import "SVProgressHUD.h"
#import "ISUserPreferenceDefine.h"
#import <DropboxSDK/DropboxSDK.h>

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
    
//    [CustomUIComponents customizeButtonWithFixedBackgroundImages:self.unlinkButton];
    
    [self.unlinkButton setTitle:NSLocalizedString(@"btn_title_unlink", nil) forState:UIControlStateNormal];
    self.unlinkButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    self.tableView.backgroundView = nil;
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

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case kLocalShareSection:
        {
            switch (indexPath.row) {
                case 0://wifi
                {
                    ISWifiViewController* wifiController = [[ISWifiViewController alloc] init];
                    [self.navigationController pushViewController:wifiController animated:YES];
                }
                    break;
                case 1://bluetooth
                {
                    ISBluetoothViewController* bluetooth = [[ISBluetoothViewController alloc] init];
                    [self.navigationController pushViewController:bluetooth animated:YES];
                }
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
            break;
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
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentitier = @"FileShareTableviewCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentitier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentitier];
    }
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = nil;
    
    switch (indexPath.section) {
        case kLocalShareSection:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UISwitch* wifiSwitch = [[UISwitch alloc] init];
                    [wifiSwitch addTarget:self action:@selector(wifiSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    wifiSwitch.on = [JJHTTPSerivce isServiceRunning];
                    cell.textLabel.text = NSLocalizedString(@"cell_title_wifishare", nil);
                    cell.accessoryView = wifiSwitch;
                    if ([JJHTTPSerivce isServiceRunning]){
                        cell.detailTextLabel.text = [[JJHTTPSerivce sharedSerivce] fullURLString];
                    }
                }
                    break;
                case 1:
                {
                    UISwitch* bluetoothSwitch = [[UISwitch alloc] init];
                    [bluetoothSwitch addTarget:self action:@selector(bluetoothSwitchChanged:) forControlEvents:UIControlEventValueChanged];
//                    bluetoothSwitch.on = [JJHTTPSerivce isServiceRunning];
                    cell.textLabel.text = NSLocalizedString(@"cell_title_bluetooth", nil);
//                    cell.accessoryView = bluetoothSwitch;
                    NSString* peerName = [[JJBTFileSharer defaultSharer] nameOfPair];
                    cell.detailTextLabel.text = (peerName.length > 0)?peerName:NSLocalizedString(@"cell_title_notconnected", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
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
                {
                    cell.textLabel.text = @"Dropbox";
                    if ([[DBSession sharedSession] isLinked]){
                        //add unlink button
                        cell.accessoryView = self.unlinkButton;
                    }
                }
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

#pragma mark - action
-(void)wifiSwitchChanged:(id)sender{
    
    static CGFloat duration = 2.0f;
    
    UISwitch* wifiSwitch = (UISwitch*)sender;
    if (wifiSwitch.on){
        if ([[JJHTTPSerivce sharedSerivce] startService]){
            [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_httpserverstartfinished", nil) duration:duration animated:YES];
            [ISUserPreferenceDefine setHttpShareStarted:YES];
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"status_message_httpserverstartfailed", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:nil];
            [alert show];
            [wifiSwitch setOn:NO animated:YES];
        };
    }else{
        if ([[JJHTTPSerivce sharedSerivce] stopService]){
            [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_httpserverstopfinished", nil) duration:duration animated:YES];
            [ISUserPreferenceDefine setHttpShareStarted:NO];
        }else{
//            [BWStatusBarOverlay showErrorWithMessage:NSLocalizedString(@"status_message_httpserverstopfailed", nil) duration:duration animated:YES];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"status_message_httpserverstopfailed" delegate:nil cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:nil];
            [alert show];
            [wifiSwitch setOn:YES animated:YES];
        };
    }
    
    [self.tableView reloadData];
}

-(void)bluetoothSwitchChanged:(id)sender{
    UISwitch* bluetoothSwitch = (UISwitch*)sender;
    if (bluetoothSwitch.on){
        //enable bluetooth
    }else{
        //disable bluetooth
    }
}

-(IBAction)unlinkDropbox:(id)sender{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"progress_message_dropboxunlinked", nil) duration:1.5];
    [[DBSession sharedSession] unlinkAll];
    [self.tableView reloadData];
}

@end
