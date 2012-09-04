//
//  ISiCloudServiceViewController.m
//  iShare
//
//  Created by Jin Jin on 12-8-26.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISiCloudServiceViewController.h"
#import "ISiCouldDataSource.h"
#import "FileListItem.h"
#import "SVProgressHUD.h"

#define kDownloadAlertViewTag   0
#define kUploadAlertViewTag     1

@interface ISiCloudServiceViewController ()

@property (nonatomic, strong) NSURL* baseURL;
@property (nonatomic, strong) NSArray* selectedFiles;
@property (nonatomic, copy) NSString* downloadFilepath;
@property (nonatomic, copy) NSString* downloadToFolder;

@end

@implementation ISiCloudServiceViewController

- (id)initWithWorkingPath:(NSString *)workingPath{
    self = [super initWithWorkingPath:workingPath];
    if (self){
        self.baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (self.workingPath.length == 0) {
            self.workingPath = [self.baseURL path];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = ([self.workingPath isEqualToString:[self.baseURL path]])?@"iCloud":[self.workingPath lastPathComponent];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark - override super class
-(ISShareServiceBaseDataSource*)createModel{
    return [[ISiCouldDataSource alloc] initWithWorkingPath:self.workingPath];
}

-(BOOL)serviceAutherized{
    NSURL* url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return url != nil;
}

-(void)autherizeService{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"progress_message_noicloudsetup", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:nil];
    [alertView show];
    [self autherizeFailed];
}

-(UIViewController*)controllerForChildFolder:(NSString *)folderPath{
    return [[ISiCloudServiceViewController alloc] initWithWorkingPath:folderPath];
}

-(void)deleteFileAtPath:(NSString *)filePath{
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error){
        [self deleteFailed:error];
    }else{
        [self deleteFinished];
    }
}

-(void)createNewFolder:(NSString *)folderName{
    NSString* folderPath = [self.workingPath stringByAppendingPathComponent:folderName];
    
    NSError* error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (error){
        [self folderCreateFailed:error];
    }else{
        [self folderCreateFinished];
    }
}

-(void)downloadRemoteFile:(NSString*)remotePath toFolder:(NSString*)folder{
    NSString* destinationFile = [folder stringByAppendingPathComponent:[remotePath lastPathComponent]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFile]){
        self.downloadFilepath = remotePath;
        self.downloadToFolder = folder;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_message_filealreadyexists", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:NSLocalizedString(@"btn_title_confirm", nil), nil];
        [alert show];
    }else{
        [self downloadiCloudFile:remotePath toFolder:folder override:NO];
    }
}

-(void)downloadiCloudFile:(NSString*)iCloudFile toFolder:(NSString*)folder override:(BOOL)override{
    
    NSString* destinationFile = [folder stringByAppendingPathComponent:[iCloudFile lastPathComponent]];
                                 
    if (override){
        [[NSFileManager defaultManager] removeItemAtPath:destinationFile error:NULL];
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:iCloudFile toPath:destinationFile error:NULL];
    
}

-(void)uploadSelectedFiles:(NSArray*)selectedFiles{
    //判断是否存在同名文件
    __block BOOL alreadyExists = NO;
    [selectedFiles enumerateObjectsUsingBlock:^(FileListItem* fileItem, NSUInteger idx, BOOL* stop){
        NSString* filename = [fileItem.filePath lastPathComponent];
        NSString* filePath = [self.workingPath stringByAppendingPathComponent:filename];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES){
            *stop = YES;
            alreadyExists = YES;
        }
    }];
    
    if (alreadyExists){
        self.selectedFiles = selectedFiles;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_message_filealreadyexists", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:NSLocalizedString(@"btn_title_confirm", nil), nil];
        [alert show];
    }else{
        [self uploadFilesToiCloud:selectedFiles override:NO];
    }
}

-(void)uploadFilesToiCloud:(NSArray*)selectedFiles override:(BOOL)override{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [selectedFiles enumerateObjectsUsingBlock:^(FileListItem* fileItem, NSUInteger idx, BOOL* stop){
            NSString* destinationFilepath = [self.workingPath stringByAppendingPathComponent:[fileItem.filePath lastPathComponent]];
            NSError* error = nil;
            if (override){
                [[NSFileManager defaultManager] removeItemAtPath:destinationFilepath error:NULL];
            }
            [[NSFileManager defaultManager] copyItemAtPath:fileItem.filePath toPath:destinationFilepath error:&error];
            if (error){
                NSLog(@"file upload error: %@", [error localizedDescription]);
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self uploadFinished];
        });
    });
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kUploadAlertViewTag:
            [self uploadFilesToiCloud:self.selectedFiles override:(buttonIndex == 1)];
            break;
        case kDownloadAlertViewTag:
            [self downloadiCloudFile:self.downloadFilepath toFolder:self.downloadToFolder override:(buttonIndex == 1)];
            break;
        default:
            break;
    }

}
@end
