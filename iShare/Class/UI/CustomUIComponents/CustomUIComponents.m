//
//  CustomUIComponents.m
//  iShare
//
//  Created by Jin Jin on 12-8-4.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "CustomUIComponents.h"

@implementation CustomUIComponents

+(UIBarButtonItem*)customBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action{
    UIImage* originNormal = [UIImage imageNamed:@"btn_title_bar_rect"];
    UIImage* resizableNormal = [originNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    
    UIImage* originPressed = [UIImage imageNamed:@"btn_title_bar_rect_pressed"];
    UIImage* resizablePressed = [originPressed resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];[UIImage imageNamed:@""];
    
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
    
    [barButton setBackgroundImage:resizableNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButton setBackgroundImage:resizablePressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    return barButton;
}

+(UIBarButtonItem*)customBackButton{
    
}

@end
