//
//  ViewController.m
//  ImageCatDemo
//
//  Created by 梁成友 on 15/12/9.
//  Copyright © 2015年 梁成友. All rights reserved.
//

#import "ViewController.h"
#import "ImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ImageView *imageCut = [[ImageView alloc] initWithImage:[UIImage imageNamed:@"cs.jpg"] cropFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0 andFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:imageCut];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
