//
//  FileBrowserController.h
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenu.h"

@interface ISFileBrowserController : UIViewController<UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIDocumentInteractionControllerDelegate, QuadCurveMenuDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIView* tableHeaderView;
@property (nonatomic, strong) IBOutlet UITextField* searchField;
@property (nonatomic, strong) IBOutlet UISegmentedControl* typeSegmented;

@property (nonatomic, strong) IBOutlet UIBarButtonItem* actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* doneEditButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* moveButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* duplicateButton;

-(id)initWithFilePath:(NSString*)filePath;

-(IBAction)actionButtonIsClicked:(id)sender;
-(IBAction)typeSegmentClicked:(id)sender;
-(IBAction)searchFieldValueChanged:(id)sender;
-(IBAction)doneEditButtonClicked:(id)sender;
-(IBAction)moveButtonClicked:(id)sender;
-(IBAction)deleteButtonClicked:(id)sender;
-(IBAction)cuplicateButtonClicked:(id)sender;

@end
