//
//  AppDimensions.h
//  InstaCollage
//
//  Created by Admin on 9/21/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface AppDimensions : NSObject

/// Privides rotation sensitive screen dimensions
+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
