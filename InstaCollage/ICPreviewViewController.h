//
//  ICPreviewViewController.h
//  InstaCollage
//
//  Created by Admin on 9/21/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollageMaker.h"
#import <MessageUI/MessageUI.h>

@interface ICPreviewViewController : UIViewController <UIScrollViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *imagesToMerge;

@end
