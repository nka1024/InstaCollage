//
//  ICRootView.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICRootView.h"

@implementation ICRootView

@synthesize submitButton = _submitButton;
@synthesize textField = _textField;

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
//        _textField.text = @"katerina_kg";
//        _textField.text = @"zlata_markelova";
//        _textField.text = @"zhannasm";
        self.textField.text = @"mirgaeva_galinka";
        
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
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_submitButton
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
        
    }
    return self;
}

@end
