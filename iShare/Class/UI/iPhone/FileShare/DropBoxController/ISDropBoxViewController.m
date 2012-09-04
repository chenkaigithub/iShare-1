//
//  ISDropBoxViewController.m
//  iShare
//
//  Created by Jin Jin on 12-8-26.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISDropBoxViewController.h"
#import "ISDropBoxDataSource.h"

#define kDropboxAuthFailedAlertViewTag 100

@interface ISDropBoxViewController (){
    BOOL _isAutherizing;
}

@property (nonatomic, strong) DBRestClient* dbClient;

@end

@implementation ISDropBoxViewController

- (id)initWithWorkingPath:(NSString *)workingPath
{
    self = [super initWithWorkingPath:workingPath];
    if (self) {
        // Custom initialization
        [self setupDropboxSession];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ([self.workingPath isEqualToDropboxPath:@"/"])?@"Dropbox":[self.workingPath lastPathComponent];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_isAutherizing){
        [self.dataSource startLoading];
        _isAutherizing = NO;
    }
}

-(ISShareServiceBaseDataSource*)createModel{
    return [[ISDropBoxDataSource alloc] initWithWorkingPath:self.workingPath];
}

-(void)setupDropboxSession{
    NSString* appKey = @"u4pqeo7i6pfxnx1";
	NSString* appSecret = @"1i6qgm4rywi0hrn";
	NSString *root = kDBRootDropbox;
	DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
}

#pragma mark - dropbox delegate
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_dropboxauthfailed", nil) message:NSLocalizedString(@"alert_message_dropboxauthfailed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:nil];
    alertView.tag = kDropboxAuthFailedAlertViewTag;
    [alertView show];
}

-(void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder{
    [self folderCreateFinished];
}

-(void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error{
    [self folderCreateFailed:error];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    [self deleteFinished];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    [self deleteFailed:error];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kDropboxAuthFailedAlertViewTag:
            [self autherizeFailed];
            break;
        default:
            break;
    }
}

#pragma mark - override super class
-(BOOL)serviceAutherized{
    return [[DBSession sharedSession] isLinked];
}

-(void)autherizeService{
    _isAutherizing = YES;
    [[DBSession sharedSession] linkFromController:self];
}

-(UIViewController*)controllerForChildFolder:(NSString *)folderPath{
    return [[ISDropBoxViewController alloc] initWithWorkingPath:folderPath];
}

-(void)deleteFileAtPath:(NSString *)filePath{
    [self.dbClient cancelAllRequests];
    self.dbClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.dbClient.delegate = self;
    [self.dbClient deletePath:filePath];
}

-(void)createNewFolder:(NSString *)folderName{
    [self.dbClient cancelAllRequests];
    self.dbClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.dbClient.delegate = self;
    [self.dbClient createFolder:[self.workingPath stringByAppendingPathComponent:folderName]];
}

-(void)downloadRemoteFile:(NSString*)remotePath toFolder:(NSString*)folder{
    
}

@end
