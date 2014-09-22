//
//  InstagramFetcher.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "InstagramAPIHelper.h"

@implementation InstagramAPIHelper

+(NSURL *)makeUserSearchURLWithQuery:(NSString *)query
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&client_id=%@", query, INSTAGRAM_CLIENT_ID];
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


+(NSURL *)makeUserMediaURL:(NSString *)userId
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", userId, INSTAGRAM_CLIENT_ID];
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


+(NSString *)extractUserId:(NSDictionary *)data forUsername:(NSString *)username{
    
    NSArray *users = [data valueForKey:@"data"];
    NSString *userId = nil;

    for (NSDictionary *userData in users)
    {
        NSString *currentUsername = [userData objectForKey:@"username"];
        if ([currentUsername.lowercaseString isEqualToString:username.lowercaseString])
        {
            userId = [userData objectForKey:@"id"];
        }
    }
    
    return userId;
}

+(NSString *)extractThumbnailURL:(NSDictionary *)data
{
    return [data valueForKeyPath:INSTAGRAM_PATH_MEDIA_THUMBNAIL];
}

+(NSURL *)extractNextURL:(NSDictionary *)data
{
    return [NSURL URLWithString:[data valueForKeyPath:INSTAGRAM_PAGINATION_NEXT_URL]];
}


+(NSArray *)extractPhotos:(NSDictionary *)data
{
    NSArray *allMedia = [data valueForKey:@"data"];
    NSMutableArray *photos = [NSMutableArray array];
    
    for (NSDictionary *media in allMedia)
    {
        NSString *mediaType = [media valueForKeyPath:INSTAGRAM_PATH_MEDIA_TYPE];
        if ([mediaType.lowercaseString isEqualToString:INSTAGRAM_MEDIA_TYPE_IMAGE])
        {
            [photos insertObject:media atIndex:photos.count];
        }
    }
    
    return photos;
}

+(NSMutableArray *)sortPhotosByLikesCount:(NSArray *)photos
{
    NSArray *sortedPhotos = [photos sortedArrayWithOptions:0
       usingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
           
           NSComparisonResult result = NSOrderedSame;
           
           NSString *obj1Likes = [obj1 valueForKeyPath:INSTAGRAM_PATH_LIKES_COUNT];
           NSString *obj2Likes = [obj2 valueForKeyPath:INSTAGRAM_PATH_LIKES_COUNT];
           
           if (obj1Likes.integerValue < obj2Likes.integerValue)
           {
               result = NSOrderedDescending;
           }
           else if (obj1Likes.integerValue > obj2Likes.integerValue)
           {
               result = NSOrderedAscending;
           }
           return result;
       }];
    
    return sortedPhotos.mutableCopy;
}

@end
