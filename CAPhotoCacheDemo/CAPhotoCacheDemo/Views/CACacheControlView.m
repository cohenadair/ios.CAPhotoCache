//
//  CACacheControlView.m
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-24.
//
//  CAPhotoCache is a robust photo caching system for iOS.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//
//  For the full copyright and license information, please
//  view the LICENSE file that was distributed with this
//  source code.
//

#import "CACacheControlView.h"
#import "CAPhotoManager.h"

static NSInteger const INDEX_ENABLED = 0;
static NSInteger const INDEX_DISABLED = 1;

static NSString *const TITLE_ENABLED = @"With cache";
static NSString *const TITLE_DISABLED = @"Without cache";

@implementation CACacheControlView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self load];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self load];
    }
    
    return self;
}

- (void)load {
    // Update the frame size.
    CGRect frame = self.frame;
    frame.size.width = 300;
    self.frame = frame;
    
    // Add options.
    [self removeAllSegments];
    
    [self insertSegmentWithTitle:TITLE_ENABLED atIndex:INDEX_ENABLED animated:NO];
    [self insertSegmentWithTitle:TITLE_DISABLED atIndex:INDEX_DISABLED animated:NO];
    
    self.selectedSegmentIndex = 0;
    
    // Add targets.
    [self addTarget:self
             action:@selector(onValueChanged)
   forControlEvents:UIControlEventValueChanged];
}

- (void)onValueChanged {
    [CAPhotoManager sharedPhotoManager].cacheEnabled = self.selectedSegmentIndex == INDEX_ENABLED;
}

@end
