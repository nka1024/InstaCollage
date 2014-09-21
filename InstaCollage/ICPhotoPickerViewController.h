//
//  ICPhotoPickerViewController.h
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramAPIHelper.h"
#import "ICPhotoPickerView.h"
#import "ICPhotoPickerCell.h"
#import "ICPreviewViewController.h"

@interface ICPhotoPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>



@property (strong, nonatomic) NSString *username;



@end
