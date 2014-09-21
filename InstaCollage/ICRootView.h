//
//  ICRootView.h
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollageMaker.h"

@interface ICRootView : UIView

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end
