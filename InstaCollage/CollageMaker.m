//
//  CollageMaker.m
//  InstaCollage
//
//  Created by Admin on 9/20/14.
//  Copyright (c) 2014 Kirill Nepomnyaschy. All rights reserved.
//

#import "CollageMaker.h"

@implementation CollageMaker

+(UIImage *)mergeImages:(NSArray *)images
{
    CGSize gridSize = {0,0};
    
    const NSInteger MAX_S = images.count;
    const float w = [AppDimensions currentSize].height;
    const float h = [AppDimensions currentSize].width;
    
    for (NSInteger i = 0; i < MAX_S; i++)
    {
        if (gridSize.width * gridSize.height < MAX_S)
        {
            const BOOL TOO_WIDE = ((gridSize.width + 3) * w / (w + h)) < (gridSize.height * h / (w + h));
            const BOOL LAST_COLUMN = MAX_S - i >= gridSize.height;
            
            if (TOO_WIDE && LAST_COLUMN)
            {
                gridSize.width++;
            }
            else
            {
                gridSize.height++;
            }
        } else
        {
            break;
        }
    }
    
    UIImage *sampleImage = (UIImage *)images.firstObject;
    
    const NSInteger IMAGE_WIDTH = sampleImage.size.width;
    const NSInteger IMAGE_HEIGHT = sampleImage.size.height;
    
    const NSInteger MAX_ROW = gridSize.height;
    const NSInteger MAX_COL = gridSize.width;
    
    CGSize contextSize = {(gridSize.width + 1) * IMAGE_WIDTH, (gridSize.height + 1) * IMAGE_HEIGHT};
    
    UIGraphicsBeginImageContext(contextSize);
    
    NSInteger imageIdx = 0;
    for (NSInteger rowIdx = 0; rowIdx <= MAX_ROW; rowIdx++)
    {
        for (NSInteger colIdx = 0; colIdx <= MAX_COL; colIdx++)
        {
            if (imageIdx < images.count)
            {
                UIImage * image = images[imageIdx];

                [image drawInRect:CGRectMake(colIdx * IMAGE_WIDTH,
                                             rowIdx * IMAGE_HEIGHT,
                                             IMAGE_WIDTH,
                                             IMAGE_HEIGHT)];
                imageIdx++;
            }
        }
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
