//
//  CollageMaker.h
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "AppDimensions.h"


@interface CollageMaker : NSObject

/// Merge given array of UIImage objects in a single UIImage by grid
+(UIImage *)mergeImages:(NSArray *)images;

@end
