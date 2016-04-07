//
//  ViewController.m
//  ScrollView自定义图片大小无限循环滚动
//
//  Created by mac on 16/4/6.
//  Copyright (c) 2016年 mac. All rights reserved.
//

#import "ViewController.h"
#import "NNScrollView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet NNScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *URLString = @[
                           @"http://img1.3lian.com/2015/w7/98/d/22.jpg",
                           @"http://img.61gequ.com/allimg/2011-4/201142614314278502.jpg",
                           @"http://pic15.nipic.com/20110731/8022110_162804602317_2.jpg",
                           @"http://pic.58pic.com/58pic/11/19/56/80d58PICzng.jpg",
                           @"http://pic27.nipic.com/20130217/3196253_212110287326_2.jpg"];
    NSMutableArray *arrM = [NSMutableArray array];
    //可以网络和本地加载图片 把图片URL存在imagesURL
    for (int i = 0; i<= 4; i++) {
        //1.本地boundle加载图片
        //        NSString *filename = [NSString stringWithFormat:@"ScrollView_%d.jpg",i];
        //        NSURL *URL = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        //2.网络加载图片
        NSURL *URL = [NSURL URLWithString:URLString[i]];
        
        [arrM addObject:URL];
    }
    //设置imageViewW属性为屏幕大小 可变成一般图片轮播器样式
    //    self.scrollView.imageViewW = self.view.bounds.size.width;
    //设置占位图
    self.scrollView.placeholderImage = [UIImage imageNamed:@"code4app_logo_1102"];
    self.scrollView.imagesURL = arrM;
    self.scrollView.delegate = self;
}
#pragma mark - NNScrollViewDelegate
- (void)NNScrollView:(NNScrollView *)scrollView didClickImageIndex:(NSInteger)index
{
    NSLog(@"%d",(int)index);
}


@end
