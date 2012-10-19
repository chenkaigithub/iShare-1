//
//  ISBluetoothViewController.m
//  iShare
//
//  Created by Jin Jin on 12-9-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISBluetoothViewController.h"
#import "ISBTSendingCell.h"
#import "ISBTReceivingCell.h"

@interface ISBluetoothViewController ()

@property (nonatomic, strong) GKSession* gkSession;

@property (nonatomic, strong) UIBarButtonItem* previousBackButton;
@property (nonatomic, strong) NSArray* receivingFileItem;

@end

@implementation ISBluetoothViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    JJBTFileSharer* btSharer = [JJBTFileSharer defaultSharer];
    btSharer.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"cell_title_bluetooth", nil);
    
    UILabel* sendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    sendingLabel.backgroundColor = [UIColor clearColor];
    sendingLabel.textAlignment = UITextAlignmentCenter;
    sendingLabel.font = [UIFont boldSystemFontOfSize:13];
    sendingLabel.textColor = [UIColor darkGrayColor];
    sendingLabel.shadowColor = [UIColor whiteColor];
    sendingLabel.shadowOffset = CGSizeMake(0, 1);
    sendingLabel.text = NSLocalizedString(@"label_title_sending", nil);
    self.sendingFilesTableView.tableHeaderView = sendingLabel;
    
    UILabel* receivingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    receivingLabel.backgroundColor = [UIColor clearColor];
    receivingLabel.textAlignment = UITextAlignmentCenter;
    receivingLabel.font = [UIFont boldSystemFontOfSize:13];
    receivingLabel.textColor = [UIColor darkGrayColor];
    receivingLabel.shadowColor = [UIColor whiteColor];
    receivingLabel.shadowOffset = CGSizeMake(0, 1);
    receivingLabel.text = NSLocalizedString(@"label_title_receiving", nil);
    self.receivingFilesTableView.tableHeaderView = receivingLabel;
    
    JJBTFileSharer* btSharer = [JJBTFileSharer defaultSharer];
    btSharer.delegate = self;
    
    //view background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    
    [self.disconnectButton setTitle:NSLocalizedString(@"btn_title_disconnect", nil)];
    [self.disconnectButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.disconnectButton setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1]];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(7, 7, 7, 7);
    
    UIImage* btnBackground = [[UIImage imageNamed:@"compose-add-button-background"] resizableImageWithCapInsets:insets];
    UIImage* btnBackgroundPressed = [[UIImage imageNamed:@"compose-add-button-background-pressed"] resizableImageWithCapInsets:insets];
    
    [self.showFilePickerButton setBackgroundImage:btnBackground forState:UIControlStateNormal];
    [self.showFilePickerButton setBackgroundImage:btnBackgroundPressed forState:UIControlStateHighlighted];
    [self.showImagePickerButton setBackgroundImage:btnBackground forState:UIControlStateNormal];
    [self.showImagePickerButton setBackgroundImage:btnBackgroundPressed forState:UIControlStateHighlighted];
    
    [self.showImagePickerButton setTitle:NSLocalizedString(@"btn_title_showimagepicker", nil) forState:UIControlStateNormal];
    [self.showFilePickerButton setTitle:NSLocalizedString(@"btn_title_showfilepicker", nil) forState:UIControlStateNormal];
    
    self.titleLabel.text = NSLocalizedString(@"label_title_choosecontent", nil);
    
    if ([btSharer isConnected] == NO){
        GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
        picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        picker.delegate = self;
        [picker show];
        [self changeUIToStates:GKPeerStateDisconnected];
    }else{
        [self changeUIToStates:GKPeerStateConnected];
        switch ([btSharer status]) {
            case JJBTFileSharerStatusReceiving:
                //show receiving ui
                [self showReceivingUI];
                break;
            case JJBTFileSharerStatusSending:
                //show sending ui
                [self showSendingUI];
                break;
            default:
                break;
        }
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.sendingFilesTableView.frame = self.view.bounds;
    self.receivingFilesTableView.frame = self.view.bounds;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)changeUIToStates:(GKPeerConnectionState)state{
    switch (state) {
        case GKPeerStateConnected:
            [self.navigationItem setRightBarButtonItem:self.disconnectButton animated:YES];
//            self.title
            self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"nav_title_connectedwith", nil), [[JJBTFileSharer defaultSharer] nameOfPair]];
            break;
        default:
            self.navigationItem.prompt = nil;
            //not connected
            break;
    }
}

#pragma mark - action
-(IBAction)disconnectButtonClicked:(id)sender{
    [[JJBTFileSharer defaultSharer] endSession];
}

-(IBAction)showImagePickerButtonClicked:(id)sender{
    AGImagePickerController* imagePicker = [[AGImagePickerController alloc] initWithDelegate:self];
    [self presentModalViewController:imagePicker animated:YES];
}

-(IBAction)showFilePickerButtonClicked:(id)sender{
    FilePickerViewController* filePicker = [[FilePickerViewController alloc] initWithFilePath:nil filterType:FileContentTypeAll];
    filePicker.delegate = self;
    [self presentViewController:filePicker animated:YES completion:NULL];
}

#pragma mark - UI change
-(void)showSendingUI{
    [self.view addSubview:self.sendingFilesTableView];
    self.sendingFilesTableView.frame = self.view.bounds;
    [self.sendingFilesTableView reloadData];
}

-(void)showReceivingUI{
    [self.view addSubview:self.receivingFilesTableView];
    self.receivingFilesTableView.frame = self.view.bounds;
    [self.sendingFilesTableView reloadData];
}

-(void)showOriginalUI{
    [self.sendingFilesTableView removeFromSuperview];
    [self.receivingFilesTableView removeFromSuperview];
}
#pragma mark - GK session delegate

#pragma mark - GK peer picker delegate
-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    self.gkSession = session;
    [JJBTFileSharer setDefaultGKSession:session];
    [picker dismiss];
    [self changeUIToStates:GKPeerStateConnected];
}

#pragma mark - bt file transfer delegate
//sending
-(void)sharerDidStartSending:(JJBTFileSharer *)sharer{
    //show sending view
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSendingUI];
    });
}

-(void)sharerDidStartReceiving:(JJBTFileSharer *)sharer headContent:(NSDictionary *)headContent{
    self.receivingFileItem = [headContent objectForKey:@"list"];
    //type and version
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showReceivingUI];
    });
}

-(void)sharerDidEndSending:(JJBTFileSharer *)sharer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOriginalUI];
    });
}

-(void)sharerDidEndReceiving:(JJBTFileSharer *)sharer{
    self.receivingFileItem = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOriginalUI];
    });
}

-(void)sharer:(JJBTFileSharer*)sharer willStartSendingFile:(NSString*)filePath{
    
}

-(void)sharer:(JJBTFileSharer *)sharer didSendBytes:(long long)bytes ofFile:(NSString *)filePath{
    
}
-(void)sharer:(JJBTFileSharer*)sharer finishedSendingFile:(NSString*)filePath{
    
}
//receiving
-(void)sharer:(JJBTFileSharer*)sharer didStartReceiveFiles:(NSArray *)files{
    //show receiving view
    [self showReceivingUI];
}

-(void)sharer:(JJBTFileSharer*)sharer willStartReceivingFile:(NSString*)filePath{
    
}
-(void)sharer:(JJBTFileSharer *)sharer didReceiveBytes:(long long)bytes ofFile:(NSString *)filePath{
    
}


-(void)sharer:(JJBTFileSharer*)sharer finishedReceivingFile:(NSString*)filePath savingPath:(NSString*)savingPath{
    
}

-(void)sharer:(JJBTFileSharer*)sharer currentTransitionFailed:(NSError*)error{
    
}
-(void)sharerTransitionCancelled:(JJBTFileSharer*)sharer{
    
}

-(void)sharerIsDisconnectedWithPair:(JJBTFileSharer*)sharer{
    [self changeUIToStates:GKPeerStateDisconnected];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Image Picker delegate
-(void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    [[JJBTFileSharer defaultSharer] sendPhotos:info];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - File Picker delegate
-(void)filePicker:(FilePickerViewController *)filePicker finishedWithPickedPaths:(NSArray *)pickedPaths{
    [[JJBTFileSharer defaultSharer] sendFiles:pickedPaths];
    [filePicker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)filePickerCancelled:(FilePickerViewController *)filePicker{
    [filePicker dismissViewControllerAnimated:YES completion:NULL];    
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - table view datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.sendingFilesTableView){
        return [[JJBTFileSharer defaultSharer] countOfSendingFiles];
    }else if (tableView == self.receivingFilesTableView){
        return [self.receivingFileItem count];
    }
    
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.sendingFilesTableView){
        static NSString* SendingCellIdentity = @"SendingCellIdentity";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SendingCellIdentity];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ISBTSendingCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        NSArray* senders = [[JJBTFileSharer defaultSharer] allSenders];
        JJBTSender* sender = [senders objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [sender name];
        
        return cell;
    }else{
        //receiving cell
        static NSString* ReceivingCellIdentity = @"ReceivingCellIdentity";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ReceivingCellIdentity];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ISBTReceivingCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        cell.textLabel.text = [[self.receivingFileItem objectAtIndex:indexPath.row] objectForKey:@"filename"];
        cell.detailTextLabel.text = [[self.receivingFileItem objectAtIndex:indexPath.row] objectForKey:@"size"];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}


@end
