//
//  ICPhotoPickerView.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICPhotoPickerView.h"

@implementation ICPhotoPickerView

-(instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        NSInteger size = [AppDimensions currentSize].width / 3;
        
        layout.itemSize = (CGSize){size, size};
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        self.allowsMultipleSelection = YES;
    }
    return self;
}

@end
