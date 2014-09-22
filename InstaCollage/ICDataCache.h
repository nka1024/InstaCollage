//
//  ICDataCache.h
//  InstaCollage
//
//  Created by Admin on 9/22/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICDataCache : NSObject

@property (strong, nonatomic) NSMutableDictionary *data;

+(instancetype)sharedInstance;

@end
