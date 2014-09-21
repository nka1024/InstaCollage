//
//  ICRootViewController.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICRootViewController.h"

@interface ICRootViewController ()

@property (strong, nonatomic) ICRootView *rootView;

@end

@implementation ICRootViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.view = self.rootView = [[ICRootView alloc] init];
        
        [self.rootView.submitButton addTarget:self
                                       action:@selector(handleSumbitClick:)
                             forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)handleSumbitClick:(id)action
{
    ICPhotoPickerViewController *photoPickerVC = [[ICPhotoPickerViewController alloc] init];
    
    photoPickerVC.username = self.rootView.textField.text;
    
    [self.navigationController pushViewController:photoPickerVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
