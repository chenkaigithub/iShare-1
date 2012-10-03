//
//  CustomUIComponents.m
//  iShare
//
//  Created by Jin Jin on 12-8-4.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "CustomUIComponents.h"

@implementation CustomUIComponents

+(void)customizeBarButton{
    UIEdgeInsets barBtnInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    
    UIImage* originNormal = [UIImage imageNamed:@"btn_title_bar_rect"];
    UIImage* resizableNormal = [originNormal resizableImageWithCapInsets:barBtnInsets];
    UIImage* originPressed = [UIImage imageNamed:@"btn_title_bar_rect_pressed"];
    UIImage* resizablePressed = [originPressed resizableImageWithCapInsets:barBtnInsets];
    
    [[UIBarButtonItem appearance] setBackgroundImage:resizableNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:resizablePressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}

+(void)customizeBackButton{
    UIEdgeInsets backBtnInsets = UIEdgeInsetsMake(0, 14, 0, 5);
    
    UIImage* originNormal = [UIImage imageNamed:@"btn_title_bar_back"];
    UIImage* resizableNormal = [originNormal resizableImageWithCapInsets:backBtnInsets];
    UIImage* originPressed = [UIImage imageNamed:@"btn_title_bar_back_pressed"];
    UIImage* resizablePressed = [originPressed resizableImageWithCapInsets:backBtnInsets];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:resizableNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:resizablePressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}

+(void)customizeNavigationBar{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_title_bar"] forBarMetrics:UIBarMetricsDefault];
}

+(void)customizeTableView{
//    [[UITableView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]]];
//    [[UITableView appearance] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_texture"]]];
}

+(void)customizeButton{
    UIEdgeInsets btnInsets = UIEdgeInsetsMake(4, 5, 4, 5);
    
    UIImage* originNormal = [UIImage imageNamed:@"btn_default"];
    UIImage* resizableNormal = [originNormal resizableImageWithCapInsets:btnInsets];
    UIImage* originPressed = [UIImage imageNamed:@"btn_pressed"];
    UIImage* resizablePressed = [originPressed resizableImageWithCapInsets:btnInsets];
    
    [[UIButton appearance] setBackgroundImage:resizableNormal forState:UIControlStateNormal];
    [[UIButton appearance] setBackgroundImage:resizablePressed forState:UIControlStateHighlighted];
}

+(void)customizeButtonWithFixedBackgroundImages:(UIButton*)button{
    UIEdgeInsets btnInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    UIImage* originNormal = [UIImage imageNamed:@"btn_default"];
    UIImage* resizableNormal = [originNormal resizableImageWithCapInsets:btnInsets];
    UIImage* originPressed = [UIImage imageNamed:@"btn_pressed"];
    UIImage* resizablePressed = [originPressed resizableImageWithCapInsets:btnInsets];
    
    [button setBackgroundImage:resizableNormal forState:UIControlStateNormal];
    [button setBackgroundImage:resizablePressed forState:UIControlStateHighlighted];
}

+(void)customizeUI{
//    [self customizeButton];
    [self customizeBackButton];
    [self customizeBarButton];
    [self customizeNavigationBar];
    [self customizeTableView];
}

@end
