//
//  ICRootView.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICRootView.h"

@implementation ICRootView

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        ////////////////////////////////
        //
        //      Username form
        //
        ////////////////////////////////
        
        // UITextField
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
        
        // Submit button
        
        self.submitButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.submitButton setTitle:@"Давай коллаж" forState:UIControlStateNormal];
        [self.submitButton setTitleColor:self.submitButton.tintColor forState:UIControlStateNormal];
        [self.submitButton setTitleColor:[self.submitButton.tintColor colorWithAlphaComponent:0.2]
                                forState:UIControlStateHighlighted];
        
        
        NSDictionary *subviews = NSDictionaryOfVariableBindings(_textField, _submitButton);
        
        for (UIView *view in [subviews allValues])
        {
            [self addSubview:view];
            [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.submitButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textField]-[_submitButton]"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:subviews]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_textField(160)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:subviews]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_submitButton]-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:subviews]];
        
        
        
        ////////////////////////////////
        //
        //      UIActivityIndicatorView
        //
        ////////////////////////////////
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setColor:[UIColor grayColor]];
        [self.spinner setHidden:YES];
        [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.spinner];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];

        ////////////////////////////////
        //
        //      UIButton: cancel
        //
        ////////////////////////////////
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.cancelButton setHidden:YES];
        [self.cancelButton setTitle:@"Отмена" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:self.cancelButton.tintColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[self.cancelButton.tintColor colorWithAlphaComponent:0.2]
                                forState:UIControlStateHighlighted];
        
        [self addSubview:self.cancelButton];
        [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:50]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

@end
