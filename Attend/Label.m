//
//  Label.m
//  Attend
//
//  Created by Tom Pullen on 15/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import "Label.h"

@implementation Label

@synthesize verticalAlignment;

- (void)drawTextInRect:(CGRect)rect
{
    if(verticalAlignment == UIControlContentVerticalAlignmentTop) {
        
        rect.size.height = [self sizeThatFits:rect.size].height;
    }
    
    if(verticalAlignment == UIControlContentVerticalAlignmentBottom) {
        
        CGFloat height = [self sizeThatFits:rect.size].height;
        
        rect.origin.y += rect.size.height - height;
        rect.size.height = height;
    }
    
    [super drawTextInRect:rect];
}

@end
