//
//  InstagramFetcher.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "InstagramAPIHelper.h"

@implementation InstagramAPIHelper

+(NSURL*)makeUserSearchURLWithQuery:(NSString *)query {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&client_id=%@", query, INSTAGRAM_CLIENT_ID]];
}


+(NSURL*)makeUserMediaURL:(NSString *)userId{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", userId, INSTAGRAM_CLIENT_ID]];
}


+(NSString *)extractUserId:(NSDictionary *)data forUsername:(NSString *)username {
    
    NSArray *users = [data valueForKey:@"data"];
    NSString *userId = nil;

    for (NSDictionary *userData in users) {
        NSString *currentUsername = [userData objectForKey:@"username"];
        if ([currentUsername.lowercaseString isEqualToString:username.lowercaseString]) {
            userId = [userData objectForKey:@"id"];
        }
    }
    
    return userId;
}

+(NSString *)extractThumbnailURL:(NSDictionary *)data {
    return [data valueForKeyPath:INSTAGRAM_PATH_MEDIA_THUMBNAIL];
}

+(NSString *)extractNextURL:(NSDictionary *)data {
    return [data valueForKeyPath:INSTAGRAM_PAGINATION_NEXT_URL];
}


+(NSArray *)extractBestPhotos:(NSDictionary *)data count:(NSInteger)count {
    
    NSArray *unsortedMedia = [data valueForKey:@"data"];
    NSArray *bestPhotos = [NSMutableArray array];
    NSMutableArray *unsortedPhotos = [NSMutableArray array];
    
    for (NSDictionary *media in unsortedMedia) {
        NSString *mediaType = [media valueForKeyPath:INSTAGRAM_PATH_MEDIA_TYPE];
        if ([mediaType.lowercaseString isEqualToString:INSTAGRAM_MEDIA_TYPE_IMAGE]) {
            [unsortedPhotos insertObject:media atIndex:unsortedPhotos.count];
        }
    }
    
    if (count >= unsortedPhotos.count) {
        bestPhotos = unsortedPhotos;
    } else {
    
        NSArray *sortedPhotos = [unsortedPhotos sortedArrayWithOptions:0
               usingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                   NSComparisonResult result = NSOrderedSame;
                   
                   NSString *obj1Likes = [obj1 valueForKeyPath:INSTAGRAM_PATH_LIKES_COUNT];
                   NSString *obj2Likes = [obj2 valueForKeyPath:INSTAGRAM_PATH_LIKES_COUNT];
                   
                   if (obj1Likes.integerValue < obj2Likes.integerValue) {
                       result = NSOrderedDescending;
                   } else if (obj1Likes.integerValue > obj2Likes.integerValue) {
                       result = NSOrderedAscending;
                   }
                   return result;
               }];
        
        NSRange range = {0, count};
        bestPhotos = [sortedPhotos objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
    
    return bestPhotos;
}
@end
