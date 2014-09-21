//
//  ICPreviewViewController.m
//  InstaCollage
//
//  Created by Admin on 9/21/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICPreviewViewController.h"

@interface ICPreviewViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ICPreviewViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        UIBarButtonItem *sendButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                      target:self
                                                      action:@selector(handleSendButtonTap:)];
        
        self.navigationItem.rightBarButtonItem = sendButton;
        self.view = self.scrollView = [[UIScrollView alloc] init];
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.scrollView.delegate = self;
        [self.scrollView addSubview:self.imageView];
        
    }
    return self;
}


-(void)handleSendButtonTap:(id)action
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Склеено приложением InstagramCollage"];
        
        NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1);
        [mailComposer addAttachmentData:imageData
                               mimeType:@"image/jpeg"
                               fileName:@"instagram_collage.jpg"];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}


/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters & setters

-(UIImageView *)imageView
{
    if (!_imageView)  _imageView = [[UIImageView alloc] init];
    return _imageView;
}

-(UIImage *)image
{
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
    [self.imageView sizeToFit];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface implementation

-(void)setImagesToMerge:(NSArray *)imagesToMerge
{
    dispatch_queue_t mergeQ = dispatch_queue_create("merge_queqe", NULL);
    dispatch_async(mergeQ, ^{
        
        UIImage *image = [CollageMaker mergeImages:imagesToMerge];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            
            CGRect frame = [[UIScreen mainScreen] bounds];
            
            self.scrollView.minimumZoomScale = frame.size.width / self.image.size.width;
            self.scrollView.maximumZoomScale = 1;
            self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
            
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        });
    });
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

/////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end