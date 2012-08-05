//
//  FileBrowserController.h
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISFileBrowserController : UIViewController<UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

-(id)initWithFilePath:(NSString*)filePath;

@end
