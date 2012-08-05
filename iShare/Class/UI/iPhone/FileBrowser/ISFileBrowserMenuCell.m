//
//  ISFileBrowserMenuCell.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserMenuCell.h"
#import "FileListItem.h"
#import "FileBrowserNotifications.h"

@interface ISFileBrowserMenuCell()

@property (nonatomic, strong) FileListItem* item;

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

-(void)configCell:(FileListItem *)item{
    self.item = item;
}

-(FileListItem*)cellItem{
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
    NSDictionary* userInfo = @{ @"item" : self.item };
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
}

@end
