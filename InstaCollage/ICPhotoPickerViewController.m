//
//  ICPhotoPickerViewController.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICPhotoPickerViewController.h"

@interface ICPhotoPickerViewController ()

@property (strong, nonatomic) NSMutableDictionary *selectedImages;   // of UIImage
@property (strong, nonatomic) NSMutableDictionary *imageCache;  // of UIImage
@property (strong, nonatomic) ICPhotoPickerView *photoPickerView;

@end

@implementation ICPhotoPickerViewController

static NSString *PHOTO_PICKER_CELL_IDENTIFIER = @"PhotoPickerCell";

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
    ppvc.imagesToMerge = self.selectedImages.allValues;
    
    [self.navigationController pushViewController:ppvc animated:YES];
}


/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface implementation

-(void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    dispatch_async(dispatch_get_main_queue(), ^{[self.photoPickerView reloadData];});
}

-(void)setUsername:(NSString *)username
{
    _username = username;
    [self setTitle:_username];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters & Setters

-(NSMutableDictionary *)selectedImages
{
    if (!_selectedImages) _selectedImages = [[NSMutableDictionary alloc] init];
    return _selectedImages;
}
-(NSMutableDictionary *)imageCache
{
    if (!_imageCache) _imageCache = [[NSMutableDictionary alloc] init];
    return _imageCache;
}

-(ICPhotoPickerView *)photoPickerView
{
    return (ICPhotoPickerView *)self.view;
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UICollectionViewDatasource & UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url =[InstagramAPIHelper extractThumbnailURL:self.photos[indexPath.row]];

    [self.selectedImages removeObjectForKey:url];
    [self updateDoneButtonState];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url =[InstagramAPIHelper extractThumbnailURL:self.photos[indexPath.row]];
    UIImage *cachedImage = [_imageCache objectForKey:url];
    
    [self.selectedImages setObject:cachedImage forKey:url];
    [self updateDoneButtonState];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ICPhotoPickerCell *cell = [_photoPickerView dequeueReusableCellWithReuseIdentifier:@"PhotoPickerCell"
                                                                          forIndexPath:indexPath];
    NSDictionary *photoData = self.photos[indexPath.row];
    NSString *url = [InstagramAPIHelper extractThumbnailURL:photoData];
    
    UIImage *cachedImage = [self.imageCache objectForKey:url];
    
    cell.photoUrl = url;
    
    [cell setSelected:([self.selectedImages objectForKey:url] != nil)];
    
    if (cachedImage)
    {
        [cell.photoImageView setImage:cachedImage];
        [cell.photoImageView setHidden:NO];
        [cell.checkImageView setHidden:NO];
        
        NSLog(@"used cached image for url: %@", url);
    }
    else
    {
        [cell.photoImageView setImage:nil];
        [cell.photoImageView setHidden:YES];
        [cell.checkImageView setHidden:YES];
        
        NSLog(@"requested image with url: %@", url);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                if ([cell.photoUrl isEqualToString:url])
                {
                    NSData *imageData = [NSData dataWithContentsOfURL:location];
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    [self.imageCache setObject:image forKey:url];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.photoImageView setImage:image];
                        [cell.checkImageView setHidden:NO];
                        [cell.photoImageView setHidden:NO];
                        
                        [self updateDoneButtonState];
                        [cell setSelected:cell.selected];
                    });
                }
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

-(void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    NSLog(@"/!\\  LOW MEMORY WARNING!");
}

@end
