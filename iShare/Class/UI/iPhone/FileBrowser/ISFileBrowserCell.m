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
}

-(void)configCell:(FileItem *)item{
    self.item = item;
    
    self.textLabel.text = [item.filePath lastPathComponent];
    if ([[self.item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.imageView.image = [FileOperationWrap thumbnailForFile:item.filePath previewEnabled:[ISUserPreferenceDefine enableThumbnail]];
    
}

-(FileItem*)cellItem{
    return self.item;
}

@end
