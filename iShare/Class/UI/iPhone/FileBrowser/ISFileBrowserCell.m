//
//  ISFileListCell.m
//  iShare
//
//  Created by Jin Jin on 12-8-5.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISFileBrowserCell.h"
#import "FileListItem.h"

@interface ISFileBrowserCell ()

@property (nonatomic, strong) FileListItem* item;

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
    self.textLabel.highlightedTextColor = [UIColor blackColor];
}

-(void)configCell:(FileListItem *)item{
    self.item = item;
    
    self.textLabel.text = [item.filePath lastPathComponent];
    if ([[self.item.attributes fileType] isEqualToString:NSFileTypeDirectory]){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

-(FileListItem*)cellItem{
    return self.item;
}

@end
