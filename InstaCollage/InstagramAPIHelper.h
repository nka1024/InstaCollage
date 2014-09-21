//
//  InstagramFetcher.h
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INSTAGRAM_MAX_PHOTOS_TO_LOAD 99999

#define INSTAGRAM_CLIENT_ID @"83e22525ee61429ba2800406935aa1d6"

#define INSTAGRAM_PATH_LIKES_COUNT          @"likes.count"
#define INSTAGRAM_PATH_MEDIA_TYPE           @"type"
#define INSTAGRAM_PATH_MEDIA_TITLE          @"caption.text"
//#define INSTAGRAM_PATH_MEDIA_THUMBNAIL      @"images.thumbnail.url"
#define INSTAGRAM_PATH_MEDIA_THUMBNAIL      @"images.low_resolution.url"
#define INSTAGRAM_PAGINATION_NEXT_URL       @"pagination.next_url"

#define INSTAGRAM_MEDIA_TYPE_IMAGE @"image"


@interface InstagramAPIHelper : NSObject

+(NSURL*)makeUserSearchURLWithQuery:(NSString *)query;
+(NSURL*)makeUserMediaURL:(NSString *)userId;

+(NSString *)extractUserId:(NSDictionary *)data forUsername:(NSString *)username;
+(NSArray *)extractBestPhotos:(NSDictionary *)data count:(NSInteger)count;
+(NSString *)extractThumbnailURL:(NSDictionary *)data;

+(NSString *)extractNextURL:(NSDictionary *)data;
@end
