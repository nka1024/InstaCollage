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
@property (strong, nonatomic) NSMutableArray *selectedImages;   // of UIImage
@property (strong, nonatomic) NSMutableArray *fetchedPhotos;    // of NSDictionary
@property (strong, nonatomic) NSMutableDictionary *imageCache;  // of UIImage
@property (strong, nonatomic) ICPhotoPickerView *photoPickerView;

@end

@implementation ICPhotoPickerViewController

static NSString *PHOTO_PICKER_CELL_IDENTIFIER = @"PhotoPickerCell";
static const NSInteger PHOTOS_FETCH_LIMIT = 105;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(handleDoneButtonClick:)];
        [doneButton setEnabled:NO];
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.view = self.photoPickerView = [[ICPhotoPickerView alloc] init];
        
        self.photoPickerView.dataSource = self;
        self.photoPickerView.delegate = self;
        
        [[self photoPickerView] registerClass:[ICPhotoPickerCell class]
                   forCellWithReuseIdentifier:PHOTO_PICKER_CELL_IDENTIFIER];
    }
    return self;
}

-(void)handleDoneButtonClick:(id)action
{
    ICPreviewViewController* ppvc = [[ICPreviewViewController alloc] init];
    ppvc.imagesToMerge = self.selectedImages;
    
    [self.navigationController pushViewController:ppvc animated:YES];
}


/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface implementation

-(void)setUsername:(NSString *)username
{
    _username = username;
    
    self.title = username;
    [self fetchUserId];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters & Setters

-(NSMutableArray *)selectedImages
{
    if (!_selectedImages) _selectedImages = [[NSMutableArray alloc] init];
    return _selectedImages;
}
-(NSMutableDictionary *)imageCache
{
    if (!_imageCache) _imageCache = [[NSMutableDictionary alloc] init];
    return _imageCache;
}

-(NSMutableArray *)fetchedPhotos
{
    if (!_fetchedPhotos) _fetchedPhotos = [[NSMutableArray alloc] init];
    return _fetchedPhotos;
}

-(ICPhotoPickerView *)photoPickerView
{
    return (ICPhotoPickerView *)self.view;
}

-(void)setUserId:(NSString *)userId
{
    _userId = userId;
    [self startFetchingPhotos];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fetch routines

-(void)fetchUserId
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[InstagramAPIHelper makeUserSearchURLWithQuery:self.username]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
        {
            NSData *jsonResult = [NSData dataWithContentsOfURL:location];
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error)
                {
                    NSString *userId = [InstagramAPIHelper extractUserId:data forUsername:self.username];
                    NSLog(@"userName = %@", userId);
                    
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
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setColor:[UIColor whiteColor]];
    [spinner setCenter:CGPointMake(200,200)];
//    [self addSubview:spinner];

    self.view = spinner;
    
    
}

-(void)fetchPhotosChunk:(NSURLRequest *)request
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
        {
            NSData *jsonResult = [NSData dataWithContentsOfURL:location];
            NSDictionary *chunkData = [NSJSONSerialization JSONObjectWithData:jsonResult options:0 error:NULL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error)
                {
                    [self handleChunkFetchingComplete:chunkData];
                }
                else
                {
                    [self handleFetchError:[NSString stringWithFormat:@"Ошибка %ld", (long)error.code]];
                }
            });
            
        }];
    [task resume];
}

-(void)handleChunkFetchingComplete:(NSDictionary *) chunkData
{
    NSArray *photosChunk = [InstagramAPIHelper extractPhotos:chunkData];
    NSRange range = {self.fetchedPhotos.count, photosChunk.count};
    
    [self.fetchedPhotos insertObjects:photosChunk atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    NSLog(@"photos data loaded: %ld", (long)photosChunk.count);
    
    NSURL* nextChunkURL = [InstagramAPIHelper extractNextURL:chunkData];
    if (nextChunkURL && self.fetchedPhotos.count <= PHOTOS_FETCH_LIMIT)
    {
        [self fetchPhotosChunk:[NSURLRequest requestWithURL:nextChunkURL]];
    }
    else
    {
        self.fetchedPhotos = [InstagramAPIHelper sortPhotosByLikesCount:self.fetchedPhotos].mutableCopy;
        [self.photoPickerView reloadData];
        
        for (NSDictionary *photo in self.fetchedPhotos) {
            NSLog(@"%@", [photo valueForKeyPath:INSTAGRAM_PATH_LIKES_COUNT]);
        }
    }
}

-(void)handleFetchError:(NSString *)errorMessage
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                             message:errorMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    [errorAlertView show];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UICollectionViewDatasource & UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url =[InstagramAPIHelper extractThumbnailURL:_fetchedPhotos[indexPath.row]];
    UIImage *cachedImage = [_imageCache objectForKey:url];

    [self.selectedImages removeObject:cachedImage];
    
    [self updateDoneButtonState];
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url =[InstagramAPIHelper extractThumbnailURL:_fetchedPhotos[indexPath.row]];
    UIImage *cachedImage = [_imageCache objectForKey:url];
    
    for (UIImage *image in self.selectedImages)
    {
        if (image == cachedImage)
        {
            return;
        }
    }
    [self.selectedImages insertObject:cachedImage atIndex:self.selectedImages.count];
    [self updateDoneButtonState];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedPhotos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICPhotoPickerCell *cell = [_photoPickerView dequeueReusableCellWithReuseIdentifier:@"PhotoPickerCell"
                                                                          forIndexPath:indexPath];
    NSDictionary *photoData = self.fetchedPhotos[indexPath.row];
    NSString *url = [InstagramAPIHelper extractThumbnailURL:photoData];
    
    UIImage *cachedImage = [self.imageCache objectForKey:url];
    
    if (cachedImage)
    {
        [cell.photoImageView setImage:cachedImage];
        [cell.checkImageView setHidden:NO];
        NSLog(@"used cached image for url: %@", url);
    }
    else
    {
        [cell.photoImageView setImage:nil];
        [cell.checkImageView setHidden:YES];
        NSLog(@"requested image with url: %@", url);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:location];
                UIImage *image = [UIImage imageWithData:imageData];
                
                [self.imageCache setObject:image forKey:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.photoImageView setImage:image];
                    [cell.checkImageView setHidden:NO];
                    
                    [self.photoPickerView selectItemAtIndexPath:indexPath
                                                       animated:YES
                                                 scrollPosition:UICollectionViewScrollPositionNone];
                    
                    [self.selectedImages insertObject:image atIndex:self.selectedImages.count];
                    [self updateDoneButtonState];
                });
            }];
        
        [task resume];
    }
    return cell;
}


-(void)updateDoneButtonState
{
    self.navigationItem.rightBarButtonItem.enabled = self.selectedImages.count > 1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

@end
