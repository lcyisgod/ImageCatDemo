//
//  MaskView.m
//  jlb
//
//  Created by jiangjiechun on 15/12/1.
//  Copyright © 2015年 zhiqin. All rights reserved.
//

#import "MaskView.h"


@implementation MaskView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    float w = rect.size.width;
    float h = rect.size.height;
    
    float iCircleSize = 200;

    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
    
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, w/2, 0);
    CGContextAddLineToPoint(c, w, 0);
    CGContextAddLineToPoint(c, w, h);
    CGContextAddLineToPoint(c, 0, h);
    CGContextAddLineToPoint(c, 0, 0);
    CGContextAddLineToPoint(c, w/2, 0);
    CGContextAddLineToPoint(c, w/2, ([UIScreen mainScreen].bounds.size.height-iCircleSize)/2);
    CGContextAddArcToPoint(c, w/2-iCircleSize/2, ([UIScreen mainScreen].bounds.size.height-iCircleSize)/2 , w/2-iCircleSize/2, [UIScreen mainScreen].bounds.size.height/2, iCircleSize/2);
    CGContextAddArcToPoint(c, w/2-iCircleSize/2, ([UIScreen mainScreen].bounds.size.height+iCircleSize)/2, w/2, ([UIScreen mainScreen].bounds.size.height+iCircleSize)/2, iCircleSize/2);
    CGContextAddArcToPoint(c, w/2+iCircleSize/2, ([UIScreen mainScreen].bounds.size.height+iCircleSize)/2, w/2+iCircleSize/2, [UIScreen mainScreen].bounds.size.height/2, iCircleSize/2);
    CGContextAddArcToPoint(c, w/2+iCircleSize/2, ([UIScreen mainScreen].bounds.size.height-iCircleSize)/2, w/2, ([UIScreen mainScreen].bounds.size.height-iCircleSize)/2, iCircleSize/2);
    CGContextAddLineToPoint(c, w/2, 0);
    CGContextFillPath(c);
}


@end
