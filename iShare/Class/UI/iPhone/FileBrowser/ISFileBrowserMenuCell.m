//
//  ISFileBrowserMenuCell.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserMenuCell.h"
#import "FileItem.h"
#import "FileBrowserNotifications.h"

@interface ISFileBrowserMenuCell()

@property (nonatomic, strong) FileItem* item;

@end

@implementation ISFileBrowserMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_swipe_tile"]];
    [self.contentView addSubview:self.containerView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configCell:(FileItem *)item{
    self.item = item;
    if ([[item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        self.mailButton.enabled = NO;
        self.openButton.enabled = NO;
        self.zipButton.enabled = NO;
        self.mailButton.alpha = 0.5;
        self.openButton.alpha = 0.5;
        self.zipButton.alpha = 0.5;
    }else{
        self.mailButton.enabled = YES;
        self.openButton.enabled = YES;
        self.zipButton.enabled = YES;
        self.mailButton.alpha = 1;
        self.openButton.alpha = 1;
        self.zipButton.alpha = 1;
    }
}

-(FileItem*)cellItem{
    return self.item;
}

-(IBAction)deleteButtonClicked:(id)sender{
    [self postNotificationName:NOTIFICATION_FILEBROWSER_DELETEBUTTONCLICKED];
}

-(IBAction)openButtonClicked:(id)sender{
    [self postNotificationName:NOTIFICAITON_FILEBROWSER_OPENINBUTTONCLICKED];
}

-(IBAction)mailButtonClicked:(id)sender{
    [self postNotificationName:NOTIFICATION_FILEBROWSER_MAILBUTTONCLICKED];
}

-(IBAction)renameButtonClicked:(id)sender{
    [self postNotificationName:NOTIFICATION_FILEBROWSER_RENAMEBUTTONCLICKED];
}

-(IBAction)zipButtonClicked:(id)sender{
    [self postNotificationName:NOTIFICATION_FILEBROWSER_ZIPBUTTONCLICKED];
}

-(void)postNotificationName:(NSString*)name{
    NSLog(@"post open in notification");
    NSDictionary* userInfo = @{ @"item" : self.item };
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self.dataSource userInfo:userInfo];
}

@end
