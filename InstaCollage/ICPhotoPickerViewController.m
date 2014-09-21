//
//  ICPhotoPickerViewController.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICPhotoPickerViewController.h"

@interface ICPhotoPickerViewController ()
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSMutableArray *bestPhotos;
@property (strong, nonatomic) ICPhotoPickerView *photoPickerView;
@property (strong, nonatomic) NSMutableDictionary *imageCache;
@end

@implementation ICPhotoPickerViewController

@synthesize username = _username;
@synthesize userId = _userId;
@synthesize photoPickerView = _photoPickerView;
@synthesize imageCache = _imageCache;
@synthesize nextURL = _nextURL;
@synthesize bestPhotos = _bestPhotos;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Склеить"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(handleSubmitButtonClick:)];
        self.navigationItem.rightBarButtonItem = submitButton;
        self.view = _photoPickerView = [[ICPhotoPickerView alloc] init];
        
        _photoPickerView.dataSource = self;
        _photoPickerView.delegate = self;
        
        [[self photoPickerView] registerClass:[ICPhotoPickerCell class] forCellWithReuseIdentifier:@"PhotoPickerCell"];
    }
    return self;
}

-(void)handleSubmitButtonClick:(id)action {
    ICPreviewViewController* ppvc = [[ICPreviewViewController alloc] init];
    ppvc.imagesToMerge = _imageCache;
    
    [self.navigationController pushViewController:ppvc animated:YES];
}

-(NSMutableDictionary *)imageCache {
    if (!_imageCache) {
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    return _imageCache;
}

-(NSMutableArray *)bestPhotos {
    if (!_bestPhotos) {
        _bestPhotos = [[NSMutableArray alloc] init];
    }
    return _bestPhotos;
}


-(void)viewDidLoad {
    [super viewDidLoad];
}

-(ICPhotoPickerView *)photoPickerView {
    return (ICPhotoPickerView *)self.view;
}

-(void)setUserId:(NSString *)userId {
    _userId = userId;
    
    [self fetchUserPhotos];
}


/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface implementation

-(void)setUsername:(NSString *)username {
    _username = username;
    
    self.title = username;
    [self fetchUserId];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fetch routines

-(void)fetchUserId
{
    if (self.username) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[InstagramAPIHelper makeUserSearchURLWithQuery:self.username]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                if (!error) {
                    NSData *jsonResult = [NSData dataWithContentsOfURL:location];
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];
                    self.userId = [InstagramAPIHelper extractUserId:data forUsername:_username];
                
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.photoPickerView showErrorText:@"Error: can't find user id"];
                    });
                }
            }];
        
        [task resume];
    }
}

-(void)fetchUserPhotos {
    
    if (self.userId) {
        
        NSURL *url = _nextURL ? [NSURL URLWithString:_nextURL] : [InstagramAPIHelper makeUserMediaURL:_userId];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSLog(@"fetching photos: %@", url);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                if (!error) {
                    NSData *jsonResult = [NSData dataWithContentsOfURL:location];
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];
                    
                    NSArray *bulkPhotos = [InstagramAPIHelper extractBestPhotos:data count:99];
                    NSRange range = {self.bestPhotos.count, bulkPhotos.count};
 
                    [_bestPhotos insertObjects:bulkPhotos atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    
                    NSLog(@"photos loaded: %ld", (long)bulkPhotos.count);

                    _nextURL = [InstagramAPIHelper extractNextURL:data];
                    if (_nextURL && self.bestPhotos.count <= INSTAGRAM_MAX_PHOTOS_TO_LOAD) {
                        [self fetchUserPhotos];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_photoPickerView reloadData];
                            NSLog(@"urls loaded");
                        });
                    }
                    
                    
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.photoPickerView showErrorText:@"Error: can't get photos"];
                    });
                }
            }];
        [task resume];
    }
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bestPhotos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ICPhotoPickerCell *cell = [_photoPickerView dequeueReusableCellWithReuseIdentifier:@"PhotoPickerCell"
                                                                          forIndexPath:indexPath];

    NSDictionary *photoData = _bestPhotos[indexPath.row];
    NSString *url = [InstagramAPIHelper extractThumbnailURL:photoData];
    
    UIImage *cachedImage = [self.imageCache objectForKey:url];
    
    if (cachedImage) {
        [cell.photoImageView setImage:cachedImage];
        [cell.checkImageView setHidden:NO];
        NSLog(@"used cached image for url: %@", url);
    }
    else {
        [cell.photoImageView setImage:nil];
        [cell.checkImageView setHidden:YES];
        
        NSLog(@"requested image with url: %@", url);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:location];
                UIImage *image = [UIImage imageWithData:imageData];
                
                [self.imageCache setObject:image forKey:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.photoImageView setImage:image];
                    [cell.checkImageView setHidden:NO];
                    [_photoPickerView selectItemAtIndexPath:indexPath
                                                   animated:YES
                                             scrollPosition:UICollectionViewScrollPositionNone];
                    
                });
            }];
        
        [task resume];
    }
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

@end
