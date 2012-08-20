//
//  FilePickerViewController.h
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilePickerDataSource.h"

typedef void(^FilePickerCompletionBlock)(NSString*);

@class FilePickerViewController;

@protocol FilePickerViewControllerDelegate <NSObject>

@optional
-(void)filePickerCancelled:(FilePickerViewController*)filePicker;
-(void)filePicker:(FilePickerViewController*)filePicker finishedWithPickedPaths:(NSArray*)pickedPaths;

@end

@interface FilePickerViewController : UIViewController<UITableViewDelegate>

-(id)initWithFilePath:(NSString*)filePath pickerType:(FilePickerType)type;

@property (nonatomic, copy) FilePickerCompletionBlock completionBlock;

@property (nonatomic, readonly) NSString* currentDirectory;
@property (nonatomic, weak) id<FilePickerViewControllerDelegate> delegate;


@end
