//
//  CATableViewCell.m
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-27.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//
//  For the full copyright and license information, please
//  view the LICENSE file that was distributed with this
//  source code.
//

#import "CATableViewCell.h"

@implementation CATableViewCell

+ (NSString *)IDENTIFIER {
    return @"CATableViewCell";
}

- (id)init {
    return [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CATableViewCell.IDENTIFIER];
}

@end
