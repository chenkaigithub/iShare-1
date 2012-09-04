//
//  ISShareServiceBaseController.h
//  iShare
//
//  Created by Jin Jin on 12-8-26.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISShareServiceBaseDataSource.h"

@interface ISShareServiceBaseController : UIViewController<UITableViewDelegate, UIAlertViewDelegate, ISShareServiceBaseDataSourceDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) ISShareServiceBaseDataSource* dataSource;

@property (nonatomic, strong) UIBarButtonItem* addDirectoryButton;
@property (nonatomic, strong) UIBarButtonItem* uploadButton;

@property (nonatomic, copy) NSString* workingPath;

-(void)addDirectoryButtonClicked:(id)sender;
-(void)uploadButtonClicked:(id)sender;

//need override

-(id)initWithWorkingPath:(NSString*)workingPath;

-(ISShareServiceBaseDataSource*)createModel;
-(BOOL)serviceAutherized;
-(void)autherizeService;
-(void)autherizeFailed;
-(void)deleteFileAtPath:(NSString*)filePath;
-(void)createNewFolder:(NSString*)folderName;
-(void)downloadRemoteFile:(NSString*)remotePath toFolder:(NSString*)folder;
-(void)uploadSelectedFiles:(NSArray*)selectedFiles;

-(void)deleteFinished;
-(void)deleteFailed:(NSError*)error;
-(void)downloadFinished;
-(void)downloadFailed:(NSError*)error;
-(void)uploadFinished;
-(void)uploadFailed:(NSError*)error;
-(void)folderCreateFinished;
-(void)folderCreateFailed:(NSError*)error;
-(UIViewController*)controllerForChildFolder:(NSString*)folderPath;

@end
