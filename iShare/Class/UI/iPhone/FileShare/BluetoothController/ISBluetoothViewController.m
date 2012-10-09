//
//  ISBluetoothViewController.m
//  iShare
//
//  Created by Jin Jin on 12-9-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISBluetoothViewController.h"

@interface ISBluetoothViewController ()

@property (nonatomic, strong) GKSession* gkSession;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"cell_title_bluetooth", nil);
    
    JJBTFileSharer* btSharer = [JJBTFileSharer defaultSharer];
    btSharer.delegate = self;
    
    //view background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    
    [self.disconnectButton setTitle:NSLocalizedString(@"btn_title_disconnect", nil)];
    [self.disconnectButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.disconnectButton setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1]];
    
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    picker.delegate = self;
    [picker show];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)changeUIToStates:(GKPeerConnectionState)state{
    switch (state) {
        case GKPeerStateConnected:
            [self.navigationItem setRightBarButtonItem:self.disconnectButton animated:YES];
            self.title = NSLocalizedString(@"nav_title_connected", nil);
            break;
        default:
            //not connected
            break;
    }
}

#pragma mark - action
-(IBAction)disconnectButtonClicked:(id)sender{
    [self.gkSession disconnectFromAllPeers];
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

#pragma mark - GK peer picker delegate
-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    self.gkSession = session;
    [JJBTFileSharer setDefaultGKSession:session];
    [picker dismiss];
    [self changeUIToStates:GKPeerStateConnected];
}

#pragma mark - bt file transfer delegate
-(void)sharer:(JJBTFileSharer*)sharer willSendingFiles:(NSArray*)files{
    
}
-(void)sharer:(JJBTFileSharer*)sharer willReceiveFiles:(NSArray*)files{
    
}
-(void)sharer:(JJBTFileSharer*)sharer willStartSendingFile:(NSString*)filePath{
    
}
-(void)sharer:(JJBTFileSharer*)sharer willStartReceivingFile:(NSString*)filePath{
    
}
-(void)sharer:(JJBTFileSharer*)sharer didSendPersentage:(CGFloat)persentage ofFile:(NSString*)filePath{
    
}
-(void)sharer:(JJBTFileSharer *)sharer didReceivePersentage:(CGFloat)persentage ofFile:(NSString *)filePath{
    
}
-(void)sharer:(JJBTFileSharer*)sharer finishedSendingFile:(NSString*)filePath{
    
}
-(void)sharer:(JJBTFileSharer*)sharer finishedReceivingFile:(NSString*)filePath savingPath:(NSString*)savingPath{
    
}

-(void)sharer:(JJBTFileSharer*)sharer currentTransitionFailed:(NSError*)error{
    
}
-(void)sharerTransitionCancelled:(JJBTFileSharer*)sharer{
    
}

-(void)sharerIsDisconnectedWithPair:(JJBTFileSharer*)sharer{
    
}

#pragma mark - Image Picker delegate
-(void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    [info enumerateObjectsUsingBlock:^(ALAsset* asset, NSUInteger idx, BOOL* stop){
        
    }];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - File Picker delegate
-(void)filePicker:(FilePickerViewController *)filePicker finishedWithPickedPaths:(NSArray *)pickedPaths{
    [filePicker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)filePickerCancelled:(FilePickerViewController *)filePicker{
    [filePicker dismissViewControllerAnimated:YES completion:NULL];    
}

@end
