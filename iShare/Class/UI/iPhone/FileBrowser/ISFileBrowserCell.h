//
//  ISFileListCell.h
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISFileBrowserCellInterface.h"

@interface ISFileBrowserCell : UITableViewCell<ISFileBrowserCellInterface>

@property (nonatomic, strong) IBOutlet UILabel* sizeLabel;

@end
