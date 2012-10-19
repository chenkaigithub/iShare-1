//
//  ISFileListCell.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserCell.h"
#import "FileItem.h"
#import "FileOperationWrap.h"
#import "ISUserPreferenceDefine.h"
#import "NSDictionary+FileOperationWrap.h"

@interface ISFileBrowserCell ()

@property (nonatomic, strong) FileItem* item;

@end

@implementation ISFileBrowserCell

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
    self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.sizeLabel.font = self.detailTextLabel.font;
    self.sizeLabel.textColor = self.detailTextLabel.textColor;
    [self.contentView addSubview:self.sizeLabel];
}

-(void)configCell:(FileItem *)item{
    self.item = item;
    
    self.textLabel.text = [item.filePath lastPathComponent];
    if ([[self.item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.accessoryView = nil;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        view.backgroundColor = [UIColor clearColor];
        self.accessoryView = view;
    }
    
    self.imageView.image = [FileOperationWrap thumbnailForFile:item.filePath previewEnabled:[ISUserPreferenceDefine enableThumbnail]];
    NSString* dateString = [NSString stringWithFormat:@"%@", [item.attributes modificationDateWithFormate:@"yyyy-MM-dd HH:mm"]];
    self.detailTextLabel.text = dateString;
    
    NSString* sizeString = [item.attributes normalizedFileSize];
    self.sizeLabel.text = sizeString;
    [self.sizeLabel sizeToFit];
    
    [self setNeedsLayout];
}

-(FileItem*)cellItem{
    return self.item;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect frame = self.sizeLabel.frame;
    frame.size.height = self.detailTextLabel.frame.size.height;
    frame.origin.y = self.detailTextLabel.frame.origin.y;
    frame.origin.x = self.contentView.frame.size.width - frame.size.width;
//    frame.origin.x = self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width + 120 - frame.size.width;
    self.sizeLabel.frame = frame;
}

@end
