//
//  ICDataCache.m
//  InstaCollage
//
//  Created by Admin on 9/22/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICDataCache.h"

@implementation ICDataCache

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(NSMutableDictionary *)data
{
    if (!_data) _data = [[NSMutableDictionary alloc] init];
    return  _data;
}

@end
