//
//  ImageView.m
//  ImageCatDemo
//
//  Created by 梁成友 on 15/12/9.
//  Copyright © 2015年 梁成友. All rights reserved.
//

#import "ImageView.h"
#import "MaskView.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@interface ImageView ()

@property (nonatomic, strong) UIImageView *showImgView;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *editedImage;


@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@property (nonatomic, strong) MaskView *maskView;
@property (nonatomic, assign) CGRect cutFrame;   //切图框

@property (nonatomic, assign) CGRect cropFrame;


@end

@implementation ImageView

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio andFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.cutFrame = CGRectMake(self.center.x - 100, self.center.y - 100, 200, 200);
        self.cropFrame = cropFrame;
        //放大的倍数
        self.limitRatio = limitRatio;
        //原始图片
        self.originalImage = originalImage;
        
        [self initView];
        [self initControlBtn];
    }
    return self;
}

//加载各个控件
- (void)initView {
    //添加图片
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    
    // scale to fit the screen(放大倍数调整)
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    //最近的一次调整位置
    self.latestFrame = self.oldFrame;
    //调整图片的大小和位置
    self.showImgView.frame = self.oldFrame;
    
    //保存最大范围
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addSubview:self.showImgView];
    
    //添加手势
    [self addGestureRecognizers];
    
    self.maskView = [[MaskView alloc] initWithFrame:self.bounds];
    [self addSubview:self.maskView];
}

- (void)initControlBtn {
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50.0f, 100, 50)];
    cancelBtn.backgroundColor = [UIColor blackColor];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cancelBtn.titleLabel setNumberOfLines:0];
    [cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 100.0f, self.frame.size.height - 50.0f, 100, 50)];
    confirmBtn.backgroundColor = [UIColor blackColor];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn setTitle:@"OK" forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    confirmBtn.titleLabel.textColor = [UIColor whiteColor];
    [confirmBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [confirmBtn.titleLabel setNumberOfLines:0];
    [confirmBtn setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
}

- (void)cancel:(id)sender {
    NSLog(@"123");
}

#pragma mark - 裁切图片
- (void)confirm:(id)sender {
    UIImageView *imaggeView = [[UIImageView alloc] initWithImage:[self getSubImage]];
    imaggeView.frame = CGRectMake(100, 20, 200, 200);
    imaggeView.layer.cornerRadius = imaggeView.frame.size.width/2;
    imaggeView.layer.masksToBounds = YES;
    [self addSubview:imaggeView];
}


// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture(添加捏合手势)
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture(添加拖动手势)
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler(捏合手势)
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {//当捏合开始或者改变时
        //按照比例放大
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {//当捏合结束时
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            //调整图片的位置
            self.showImgView.frame = newFrame;
            //记录尺寸
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler(平移手势)
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
//        CGFloat absCenterX = self.cutFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterX = self.maskView.center.x;
//        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat absCenterY = self.maskView.center.y;
//        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat scaleRatio = self.showImgView.frame.size.width / 200;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}
//获得捏合放大后的尺寸和位置
- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {//不支持缩小
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {//超过放大倍率
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}
//获得捏合移动后的位置
- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally（水平）
//    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
//    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    if (newFrame.origin.x > self.maskView.center.x - 100) newFrame.origin.x = self.maskView.center.x - 100;
    if (CGRectGetMaxX(newFrame) < self.maskView.center.x + 100) newFrame.origin.x = self.maskView.center.x + 100 - newFrame.size.width;

    // vertically（竖直）
//    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
//    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
//        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
//    }
    if (newFrame.origin.y > self.maskView.center.y - 100) newFrame.origin.y = self.maskView.center.y - 100;
    if (CGRectGetMaxY(newFrame) < self.maskView.center.y + 100) {
        newFrame.origin.y = self.maskView.center.y + 100 - newFrame.size.height;
    }
    // adapt horizontally rectangle
//    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
//        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
//    }
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= 200) {
        newFrame.origin.y = self.maskView.center.y + newFrame.size.height / 2;
    }
    return newFrame;
}

//裁切图片
-(UIImage *)getSubImage{
//    CGRect squareFrame = self.cropFrame;
    CGRect squareFrame = self.cutFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
//    if (self.latestFrame.size.width < self.cropFrame.size.width) {
//        CGFloat newW = self.originalImage.size.width;
//        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
//        x = 0; y = y + (h - newH) / 2;
//        w = newH; h = newH;
//    }
    if (self.latestFrame.size.width < self.cutFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cutFrame.size.height / self.cutFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }

//    if (self.latestFrame.size.height < self.cropFrame.size.height) {
//        CGFloat newH = self.originalImage.size.height;
//        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
//        x = x + (w - newW) / 2; y = 0;
//        w = newH; h = newH;
//    }
    if (self.latestFrame.size.height < self.cutFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cutFrame.size.width / self.cutFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }

    CGRect myImageRect = CGRectMake(x, y, w, h);
//    CGImageRef imageRef = self.originalImage.CGImage;
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
//    CGSize size;
//    size.width = myImageRect.size.width;
//    size.height = myImageRect.size.height;
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, myImageRect, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
//    UIGraphicsEndImageContext();
    UIImage *images = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([self.originalImage CGImage], myImageRect)];
    return images;
}



@end
