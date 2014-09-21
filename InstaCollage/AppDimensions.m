//
//  AppDimensions.m
//  InstaCollage
//
//  Created by Admin on 9/21/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "AppDimensions.h"

@implementation AppDimensions

+(CGSize) currentSize
{
    return [AppDimensions sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

@end
