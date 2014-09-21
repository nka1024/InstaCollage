//
//  ICPhotoPickerCell.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "ICPhotoPickerCell.h"

@implementation ICPhotoPickerCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 24, 24)];

        [self.contentView addSubview:self.photoImageView];
        [self.contentView addSubview:self.checkImageView];
    }
    return self;
}

-(void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkImageView.image = [UIImage imageNamed:(selected ? @"check_on.png" : @"check_off.png")];
}



@end
