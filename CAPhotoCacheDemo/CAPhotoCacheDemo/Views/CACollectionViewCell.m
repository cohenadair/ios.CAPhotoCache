//
//  CACollectionViewCell.m
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-29.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//

#import "CACollectionViewCell.h"
#import "CAUtils.h"

@implementation CACollectionViewCell

+ (NSString *)IDENTIFIER {
    return @"CACollectionViewCell";
}

+ (CGFloat)MAX_SIZE {
    return 180;
}

+ (CGSize)sizeWithSpacing:(NSInteger)spacing cellsPerRow:(NSInteger)cellsPerRow {
    CGSize result;
    result.width = result.height =
        (CAUtils.screenSizeInPoints.width - ((cellsPerRow - 1) * spacing)) / cellsPerRow;
    return result;
}

@end
