//
//  CustomUIComponents.h
//  iShare
//
//  Created by Jin Jin on 12-8-4.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomUIComponents : NSObject

+(UIBarButtonItem*)customBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+(UIBarButtonItem*)customBackButton;

@end
