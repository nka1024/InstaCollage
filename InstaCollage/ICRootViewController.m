//
//  ICRootViewController.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICRootViewController.h"

@interface ICRootViewController ()

@property (strong, nonatomic) ICRootView *rootView;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSMutableArray *fetchedPhotos;    // of NSDictionary
@property (strong, nonatomic) NSString *username;

@end

static const NSInteger PHOTOS_FETCH_LIMIT = 100;

@implementation ICRootViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.view = self.rootView = [[ICRootView alloc] init];
        
        [self.rootView.submitButton addTarget:self
                                       action:@selector(handleSumbitButtonTap:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        [self.rootView.cancelButton addTarget:self
                                       action:@selector(handleCancelButtonTap:)
                             forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)handleSumbitButtonTap:(id)action
{
    self.username = self.rootView.textField.text;
}

-(void)handleCancelButtonTap:(id)action
{
    self.sessionId = nil;
    [self stopActivityAnimationAndShowUsernameForm];
}


-(NSMutableArray *)fetchedPhotos
{
    if (!_fetchedPhotos) _fetchedPhotos = [[NSMutableArray alloc] init];
    return _fetchedPhotos;
}

-(void)setUserId:(NSString *)userId
{
    _userId = userId;
    
    [_fetchedPhotos removeAllObjects];
    
    [self startFetchingPhotos];
}


/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface implementation

-(void)setUsername:(NSString *)username
{
    _username = username;
    self.title = username;
    self.sessionId = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    
    [self startActivityAnimationAndHideUsernameForm];
    [self fetchUserId];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fetch routines

-(void)fetchUserId
{
    NSString *sessionId = self.sessionId.copy;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[InstagramAPIHelper makeUserSearchURLWithQuery:self.username]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
          NSData *jsonResult = [NSData dataWithContentsOfURL:location];
          NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];
          
          dispatch_async(dispatch_get_main_queue(), ^{
              
              if (![sessionId isEqualToString:self.sessionId])
              {
                  NSLog(@"session is invalid. stopping");
                  return;
              }
              
              if (!error)
              {
                  NSString *userId = [InstagramAPIHelper extractUserId:data forUsername:self.username];
                  
                  if (!userId)
                  {
                      [self handleFetchError:[NSString stringWithFormat:@"Пользователь %@ не найден", self.username]];
                  }
                  else
                  {
                      
                      self.userId = userId;
                  }
              }
              else
              {
                  [self handleFetchError:[NSString stringWithFormat:@"Ошибка %ld", (long)error.code]];
              }
          });
      }];
    
    [task resume];
}

-(void)startFetchingPhotos
{
    NSURL *url = [InstagramAPIHelper makeUserMediaURL:_userId];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self fetchPhotosChunk:request];
}

-(void)fetchPhotosChunk:(NSURLRequest *)request
{
    NSString *sessionId = self.sessionId.copy;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
      {
          if (![sessionId isEqualToString:self.sessionId])
          {
              NSLog(@"session is invalid. stopping");
              return;
          }
          
          NSData *jsonResult = [NSData dataWithContentsOfURL:location];
          NSDictionary *chunkData = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];
          
          dispatch_async(dispatch_get_main_queue(), ^{
              if (!error)
              {
                  [self handlePhotosChunkFetchingComplete:chunkData];
              }
              else
              {
                  [self handleFetchError:[NSString stringWithFormat:@"Ошибка %ld", (long)error.code]];
              }
          });
          
      }];
    [task resume];
}

-(void)handlePhotosChunkFetchingComplete:(NSDictionary *) chunkData
{
    
    NSArray *photosChunk = [InstagramAPIHelper extractPhotos:chunkData];
    NSRange range = {self.fetchedPhotos.count, photosChunk.count};
    
    [self.fetchedPhotos insertObjects:photosChunk atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    NSLog(@"photos data loaded: %ld", (long)self.fetchedPhotos.count);
    
    NSURL* nextChunkURL = [InstagramAPIHelper extractNextURL:chunkData];
    if (nextChunkURL && self.fetchedPhotos.count <= PHOTOS_FETCH_LIMIT)
    {
        [self fetchPhotosChunk:[NSURLRequest requestWithURL:nextChunkURL]];
    }
    else
    {
        self.fetchedPhotos = [InstagramAPIHelper sortPhotosByLikesCount:self.fetchedPhotos].mutableCopy;
        [self pushToPhotoPickerVC];
    }
}

-(void)handleFetchError:(NSString *)errorMessage
{
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                             message:errorMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    [errorAlertView show];
    
    [self stopActivityAnimationAndShowUsernameForm];
}



/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Helpers

-(void)pushToPhotoPickerVC
{
    [self stopActivityAnimationAndShowUsernameForm];
    
    ICPhotoPickerViewController *photoPickerVC = [[ICPhotoPickerViewController alloc] init];
    photoPickerVC.photos = self.fetchedPhotos;
    photoPickerVC.username = self.username;
    [self.navigationController pushViewController:photoPickerVC animated:YES];
}

-(void)startActivityAnimationAndHideUsernameForm
{
    [self.rootView.cancelButton setHidden:NO];
    [self.rootView.submitButton setHidden:YES];
    [self.rootView.textField setHidden:YES];
    [self.rootView.spinner setHidden:NO];
    [self.rootView.spinner startAnimating];
}

-(void)stopActivityAnimationAndShowUsernameForm
{
    [self.rootView.cancelButton setHidden:YES];
    [self.rootView.submitButton setHidden:NO];
    [self.rootView.textField setHidden:NO];
    [self.rootView.spinner setHidden:YES];
    [self.rootView.spinner stopAnimating];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
