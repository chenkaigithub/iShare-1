//
//  FilePickerViewController.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "FilePickerViewController.h"
#import "FilePickerContentController.h"
#import "FileBrowserNotifications.h"
#import "FilePickerDataSource.h"
#import "FileOperationWrap.h"
#import "FileListItem.h"

@interface FilePickerViewController ()

@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, assign) FilePickerType pickerType;
@property (nonatomic, strong) UINavigationController* contentNavigation;

@end

@implementation FilePickerViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWithFilePath:(NSString*)filePath pickerType:(FilePickerType)type{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self){
        self.filePath = filePath;
        self.pickerType = type;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneActionReceived:) name:NOTIFICATION_PICKERCONTENT_DONE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelActionReceived:) name:NOTIFICATION_PICKERCONTENT_CANCEL object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FilePickerContentController* content = [[FilePickerContentController alloc] initWithFilePath:self.filePath pickerType:self.pickerType];
    self.contentNavigation = [[UINavigationController alloc] initWithRootViewController:content];
    
    [self.view addSubview:self.contentNavigation.view];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.contentNavigation = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

#pragma mark - getter and setter
-(NSString*)currentDirectory{
    FilePickerContentController* contentController = (FilePickerContentController*)[self.contentNavigation topViewController];
    return contentController.filePath;
}

-(NSArray*)selectedFiles{
    FilePickerContentController* contentController = (FilePickerContentController*)[self.contentNavigation topViewController];
    return contentController.selectedFilePath;
}

#pragma mark - notification
-(void)doneActionReceived:(NSNotification*)notification{
    NSArray* pathArray = nil;
    if (self.pickerType == FilePickerTypeDirectory){
        pathArray = @[[self currentDirectory]];
    }else{
        pathArray = [self selectedFiles];
    }
    
    self.completionBlock(pathArray);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)cancelActionReceived:(NSNotification*)notification{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
