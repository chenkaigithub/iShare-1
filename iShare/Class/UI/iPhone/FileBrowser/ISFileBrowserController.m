//
//  FileBrowserController.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserController.h"
#import "FileBrowserDataSource.h"
#import "BWStatusBarOverlay.h"
#import "SVProgressHUD.h"
#import <MessageUI/MessageUI.h>

#define kNewDirectoryNameAlertViewTag 100
#define kNewTextFileNameAlertViewTag 200
#define kDeleteFilesConfirmAlertViewTag 300

@interface ISFileBrowserController ()

@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) FileBrowserDataSource* dataSource;
@property (nonatomic, strong) QuadCurveMenu* pathMenu;

@end

@implementation ISFileBrowserController

static CGFloat kMessageTransitionDuration = 1.5f;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWithFilePath:(NSString*)filePath{
    
    self = [super initWithNibName:@"ISFileBrowserController" bundle:nil];
    
    if (self){
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (filePath == nil || exists == NO || (exists == YES && isDirectory == NO)){
            self.filePath = [self defaultFilePath];
            self.title = NSLocalizedString(@"tab_title_myfiles", nil);
        }else{
            self.filePath = filePath;
            self.title = [filePath lastPathComponent];
        }
        
        self.tabBarItem.image = [UIImage imageNamed:@"ic_tab_myfiles"];
        self.tabBarItem.title = self.title;
        
        [self registorNotifications];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add path menu
    [self loadQuadCurveMenu];
    
    //customize title of action buttons
    [self.actionButton setTitle:NSLocalizedString(@"btn_title_operate", nil)];
    [self.deleteButton setTitle:NSLocalizedString(@"btn_title_delete",nil)];
    [self.moveButton setTitle:NSLocalizedString(@"btn_title_move", nil)];
    [self.duplicateButton setTitle:NSLocalizedString(@"btn_title_copy", nil)];
    
    [self.doneEditButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.deleteButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.deleteButton setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1]];
    
    self.navigationItem.rightBarButtonItem = self.actionButton;
    //search field
    UIImage* searchBack = [UIImage imageNamed:@"searches_field"];
    UIImage* resizableBack = [searchBack resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 14)];
    self.searchField.background = resizableBack;
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 44)];
    leftView.backgroundColor = [UIColor clearColor];
    self.searchField.leftView = leftView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.placeholder = NSLocalizedString(@"search_placeholder", nil);
    [self.searchField addTarget:self action:@selector(searchFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    //segment bar
    [self.typeSegmented setTitle:NSLocalizedString(@"seg_title_name", nil) forSegmentAtIndex:0];
    [self.typeSegmented setTitle:NSLocalizedString(@"seg_title_date", nil) forSegmentAtIndex:1];
    [self.typeSegmented setTitle:NSLocalizedString(@"seg_title_type", nil) forSegmentAtIndex:2];
    
    //view background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    //table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    FileBrowserDataSource* dataSource = [[FileBrowserDataSource alloc] initWithFilePath:self.filePath];
    self.dataSource = dataSource;
    self.tableView.dataSource = dataSource;
    [self.tableView reloadData];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.pathMenu = nil;
    self.tableHeaderView = nil;
    self.deleteButton = nil;
    self.moveButton = nil;
    self.doneEditButton = nil;
    self.duplicateButton = nil;
    self.actionButton = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //lay out subviews
    self.tableView.frame = self.view.bounds;
    
    CGRect frame = self.pathMenu.frame;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    
    self.pathMenu.frame = frame;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(NSString*)defaultFilePath{
    NSString* defaultFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    DebugLog(@"%@", defaultFilePath);
    return defaultFilePath;
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchField resignFirstResponder];
    [self.dataSource hideMenu];
    if (tableView.editing == NO){
        //normal mode
        FileListItem* item = [self.dataSource objectAtIndexPath:indexPath];
        if ([[item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
            ISFileBrowserController* fileBrowser = [[ISFileBrowserController alloc] initWithFilePath:item.filePath];
            [self.navigationController pushViewController:fileBrowser animated:YES];
        }else{
            //preview files by file type
            UIDocumentInteractionController* documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:item.filePath]];
            documentController.delegate = self;
            [documentController presentPreviewAnimated:YES];
        }
    }else{
        //editing mode
        NSArray* selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        if ([selectedIndexPaths count] > 0){
            [self enableActionButtons];
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.editing == YES){
        NSArray* selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        if ([selectedIndexPaths count] == 0){
            [self disableActionButtons];
        }
    }
}

-(void)enableActionButtons{
    self.moveButton.enabled = YES;
    self.duplicateButton.enabled = YES;
    self.deleteButton.enabled = YES;
}

-(void)disableActionButtons{
    self.moveButton.enabled = NO;
    self.duplicateButton.enabled = NO;
    self.deleteButton.enabled = NO;
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchField resignFirstResponder];
    if (self.dataSource.menuIsShown){
        [self.dataSource hideMenu];
    }
}


#pragma mark - button action
-(IBAction)actionButtonIsClicked:(id)sender{
    [self.searchField resignFirstResponder];
    [self.dataSource hideMenu];
    //enable edit mode
    [self startEditingMode];
}

-(IBAction)typeSegmentClicked:(id)sender{
    [self.searchField resignFirstResponder];
    UISegmentedControl* segControl = (UISegmentedControl*)sender;
    [self.dataSource sortListByOrder:segControl.selectedSegmentIndex];
    [self.tableView reloadData];
}

-(IBAction)searchFieldValueChanged:(id)sender{
    [self.dataSource setFilterKeyword:self.searchField.text];
    [self.tableView reloadData];
}

-(IBAction)doneEditButtonClicked:(id)sender{
    [self endEditingMode];
}

-(IBAction)moveButtonClicked:(id)sender{
    
}

-(IBAction)deleteButtonClicked:(id)sender{
    //show confirm alert view
    UIAlertView* deleteConfirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_deleteconfirm", nil) message:NSLocalizedString(@"alert_message_deleteconfirm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:NSLocalizedString(@"btn_title_confirm", nil), nil];
    deleteConfirmAlert.tag = kDeleteFilesConfirmAlertViewTag;
    
    [deleteConfirmAlert show];
}

-(IBAction)cuplicateButtonClicked:(id)sender{
    
}

-(IBAction)compressButtonClicked:(id)sender{
    
}

#pragma mark - Quad Cure Menu

-(void)loadQuadCurveMenu{
    
    UIImage* bkImage = [UIImage imageNamed:@"bg-menuitem"];
    UIImage* bkHighlightedImage = [UIImage imageNamed:@"bg-menuitem-highlighted"];
    [self.pathMenu removeFromSuperview];
    QuadCurveMenuItem* newDirectory = [[QuadCurveMenuItem alloc] initWithImage:bkImage highlightedImage:bkHighlightedImage ContentImage:nil highlightedContentImage:nil];
    QuadCurveMenuItem* newAlbumPhoto = [[QuadCurveMenuItem alloc] initWithImage:bkImage highlightedImage:bkHighlightedImage ContentImage:nil highlightedContentImage:nil];
    QuadCurveMenuItem* newCameraPhoto = [[QuadCurveMenuItem alloc] initWithImage:bkImage highlightedImage:bkHighlightedImage ContentImage:nil highlightedContentImage:nil];
    QuadCurveMenuItem* newText = [[QuadCurveMenuItem alloc] initWithImage:bkImage highlightedImage:bkHighlightedImage ContentImage:nil highlightedContentImage:nil];
    
    NSArray* menus = @[newDirectory, newAlbumPhoto, newCameraPhoto, newText];
    
    self.pathMenu = [[QuadCurveMenu alloc] initWithFrame:CGRectMake(0, 0, 320, 50) menus:menus];
    self.pathMenu.startPoint = CGPointMake(25, 25);
    self.pathMenu.menuWholeAngle = M_PI*2/3;
    self.pathMenu.delegate = self;
    
    [self.view addSubview:self.pathMenu];
}

-(void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx{
    //path menu is selected
    switch (idx) {
        case 0:
            //add new directory
            [self promptToCreateNewDirectory];
            break;
        case 1:
            //add new album photo
            [self promptToCreateNewImageFromAlbum];
            break;
        case 2:
            //add new camera photo
            [self promptToCreateNewImageFromCamera];
            break;
        case 3:
            //add new text file
            [self promptToCreateTextFile];
            break;
        default:
            break;
    }
}

#pragma mark - add action
-(void)promptToCreateNewDirectory{
    //show alert view to input name of directory
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_inputdirectoryname", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:NSLocalizedString(@"btn_title_confirm", nil),nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = kNewDirectoryNameAlertViewTag;
    
    [alertView show];
}

-(void)promptToCreateNewImageFromAlbum{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

-(void)promptToCreateNewImageFromCamera{
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == NO &&
        [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == NO){
        return;
    }
    UIImagePickerController* camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    camera.delegate = self;
    
    [self presentViewController:camera animated:YES completion:NULL];
}

-(void)promptToCreateTextFile{
    //show alert view to input name of text file
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_inputtextfilename", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"btn_title_cancel", nil) otherButtonTitles:NSLocalizedString(@"btn_title_confirm", nil),nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = kNewTextFileNameAlertViewTag;
    
    [alertView show];
}

#pragma mark - image picker delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData* imageData = UIImagePNGRepresentation(pickedImage);
    
    NSString* fileName = [self generateImageName];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"status_message_savingimage", nil)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self saveFile:imageData withName:fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result){
                [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newimagecreated", nil) duration:kMessageTransitionDuration animated:YES];
                [self.dataSource refresh];
                [self.tableView reloadData];
                [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"status_message_savingsuccess", nil)];
            }else{
                [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newimagecreatefailed", nil) duration:kMessageTransitionDuration animated:YES];
                [SVProgressHUD dismissWithError:NSLocalizedString(@"status_message_savingfailed", nil)];
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        });
    });
}

-(NSString*)generateImageName{
    NSString* filenameTemplate = NSLocalizedString(@"newimagename_template", nil);
    
    NSString* actualName = [NSString stringWithFormat:filenameTemplate, [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]];
    
    return [actualName stringByAppendingPathExtension:@"png"];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case kNewDirectoryNameAlertViewTag:
        {
            //create new directory
            if (buttonIndex == 1){
                //confirm
                UITextField* textField = [alertView textFieldAtIndex:0];
                NSString* folderName = textField.text;
                if ([self createDirectoryWithName:folderName]){
                    //notify create success
                    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newfoldercreated", nil) duration:kMessageTransitionDuration animated:YES];
                    //reload tableview
                    [self.dataSource refresh];
                    [self.tableView reloadData];
                }else{
                    //notify create failed
                    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newfoldercreatefailed", nil) duration:kMessageTransitionDuration animated:YES];
                }
            }
        }
            break;
        case kNewTextFileNameAlertViewTag:
        {
            //create new text file
            if (buttonIndex == 1){
                //confirm
                UITextField* textField = [alertView textFieldAtIndex:0];
                NSString* fileName = textField.text;
                NSString* fullname = [fileName stringByAppendingPathExtension:@"txt"];
                
                if ([self createFileWithName:fullname]){
                    //notify create success
                    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newtextcreated", nil) duration:kMessageTransitionDuration animated:YES];
                    //reload tableview
                    [self.dataSource refresh];
                    [self.tableView reloadData];
                }else{
                    //notify create failed
                    [BWStatusBarOverlay showSuccessWithMessage:NSLocalizedString(@"status_message_newtextcreatefailed", nil) duration:kMessageTransitionDuration animated:YES];
                }
            }
        }
            break;
        case kDeleteFilesConfirmAlertViewTag:
        {
            if (buttonIndex == 1){
                //confirm deletion
                //show waiting alert view
//                [SVProgressHUD showWithStatus:@"Deleting..."];
                [self removeFilesForSelectedIndexPaths];
//                [SVProgressHUD showSuccessWithStatus:@"Done"];
//                [self.tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - text field delegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

#pragma mark - document interaction delegate
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    NSLog(@"will send to %@", application);
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    NSLog(@"did send to %@", application);    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    NSLog(@"did send to ");    
}

-(UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

#pragma mark - create file and folder
-(BOOL)createDirectoryWithName:(NSString*)name{
    NSString* folderPath = [self.filePath stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:NULL];
}

-(BOOL)createFileWithName:(NSString*)name{
    NSString* filePath = [self.filePath stringByAppendingPathComponent:name];
    NSString* fileContent = @"";
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[fileContent dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

-(BOOL)saveFile:(NSData*)fileData withName:(NSString*)name{
    NSString* filePath = [self.filePath stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
}

-(void)removeFilesForSelectedIndexPaths{
    NSArray* selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSFileManager* fm = [NSFileManager defaultManager];
    [selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL* stop){
        FileListItem* item = [self.dataSource objectAtIndexPath:indexPath];
        [fm removeItemAtPath:item.filePath error:NULL];
    }];
    
    [self.dataSource refresh];
    
//    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
}

#pragma mark - editing mode
-(void)startEditingMode{
    //show top bar buttons
    self.navigationItem.title = nil;
    [self.navigationItem setRightBarButtonItem:self.doneEditButton animated:YES];
    NSArray* leftItems = @[self.moveButton, self.duplicateButton, self.deleteButton];
    [self.navigationItem setLeftBarButtonItems:leftItems animated:YES];
    [self disableActionButtons];
    //hide path menu
    [UIView animateWithDuration:0.2f animations:^{
        self.pathMenu.alpha = 0.0f;
    }];
    //change table view to editing mode
    [self.tableView setEditing:YES animated:YES];
}

-(void)endEditingMode{
    //hide top bar buttons;
    self.navigationItem.title = self.title;
    [self.navigationItem setRightBarButtonItem:self.actionButton animated:YES];
    [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    //show path menu
    [UIView animateWithDuration:0.2f animations:^{
        self.pathMenu.alpha = 1.0f;
    }];
    //exit editing mode
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - notification selector
-(void)registorNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(shouldShowMenu:) name:NOTIFICATION_FILEBROWSER_MENUSHOWN object:self.dataSource];
    [nc addObserver:self selector:@selector(shouldHideMenu:) name:NOTIFICATION_FILEBROWSER_MENUGONE object:self.dataSource];
    [nc addObserver:self selector:@selector(deleteFileNotificationReceived:) name:NOTIFICATION_FILEBROWSER_DELETEBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(openFileNotificationReceived:) name:NOTIFICAITON_FILEBROWSER_OPENINBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(mailFileNotificationReceived:) name:NOTIFICATION_FILEBROWSER_MAILBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(renameFileNotificationReceived:) name:NOTIFICATION_FILEBROWSER_RENAMEBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(zipFileNotificationReceived:) name:NOTIFICATION_FILEBROWSER_ZIPBUTTONCLICKED object:nil];
}

-(void)deleteFileNotificationReceived:(NSNotification*)notification{
    
}

-(void)openFileNotificationReceived:(NSNotification*)notification{
    FileListItem* item = [notification.userInfo objectForKey:@"item"];
    NSURL* URL = [NSURL fileURLWithPath:item.filePath];
    UIDocumentInteractionController* documentController = [UIDocumentInteractionController interactionControllerWithURL:URL];
    documentController.delegate = self;
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [documentController presentPreviewAnimated:YES];
//    BOOL result = [documentController presentOpenInMenuFromRect:window.frame inView:window animated:YES];
//    if (result == NO){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_message_nosuitableapp", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
//    }
}

-(void)mailFileNotificationReceived:(NSNotification*)notification{
    FileListItem* item = [notification.userInfo objectForKey:@"item"];
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
#warning TODO
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_message_nomailaccount", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

-(void)renameFileNotificationReceived:(NSNotification*)notification{
    
}

-(void)zipFileNotificationReceived:(NSNotification*)notification{
    
}

-(void)shouldShowMenu:(NSNotification*)notification{
    [self refreshTableView];
}

-(void)shouldHideMenu:(NSNotification*)notification{
    [self refreshTableView];
}

-(void)refreshTableView{
    [self.tableView beginUpdates];
    
    if (self.dataSource.removeIndex != NSNotFound){
        NSIndexPath* removeIndexPath = [NSIndexPath indexPathForRow:self.dataSource.removeIndex inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[ removeIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (self.dataSource.addIndex != NSNotFound){
        NSIndexPath* addIndexPath = [NSIndexPath indexPathForRow:self.dataSource.addIndex inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[ addIndexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

@end
