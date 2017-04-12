//
//  ImageView.h
//  ImageCatDemo
//
//  Created by 梁成友 on 15/12/9.
//  Copyright © 2015年 梁成友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIView

- (id)initWithImage:(UIImage *)originalImage
          cropFrame:(CGRect)cropFrame
    limitScaleRatio:(NSInteger)limitRatio
           andFrame:(CGRect)frame;

@end
