//
//  ISMusicPlayerController.m
//  iShare
//
//  Created by Jin Jin on 12-8-3.
//  Copyright (c) 2012年 Jin Jin. All rights reserved.
//

#import "ISMusicPlayerController.h"

@interface ISMusicPlayerController ()

@end

@implementation ISMusicPlayerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Music Player";
        self.tabBarItem.title = @"Music Player";
        self.tabBarItem.image = [UIImage imageNamed:@"ic_tab_profile"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
