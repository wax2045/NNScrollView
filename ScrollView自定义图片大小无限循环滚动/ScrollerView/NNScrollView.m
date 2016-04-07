//
//  NNScrollView.m
//  xuanHuanGunDong
//
//  Created by mac on 16/4/5.
//  Copyright © 2016年 HYJ. All rights reserved.
//

#import "NNScrollView.h"
#import "UIImageView+WebCache.h"

#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height
@interface NNScrollView()
@property (nonatomic, strong) NSArray *scrollerImageViews;
@property (nonatomic, strong) UIPageControl *pageControll;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation NNScrollView
{
    CGFloat kStep;
    int kCount;
    int kPage;
    NSTimer *kTimer;
    CGFloat kOldConteOffsetX;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setTimerInterval:(CGFloat)timerInterval
{
    _timerInterval = timerInterval;
}
- (NSArray *)scrollerImageViews
{
    if (!_scrollerImageViews) {
        NSMutableArray *arrM = [NSMutableArray array];
        NSInteger count = self.imagesURL.count;
        for (int i = 0; i < count + 4; i++) {
            //451234512布局图片：
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.userInteractionEnabled = YES;
            //1.目的是布局图片第一二个为最后两个（45）
            if (i < 2)
            {
              NSURL *url =  i == 0 ? self.imagesURL[count-2]:self.imagesURL[count-1];
                [imageView sd_setImageWithURL:url placeholderImage:self.placeholderImage];
            }
            else
            {
                //2.取余的目的是为后两个图片为前面两个（12）
                NSURL *url = self.imagesURL[(i-2)%count];
                [imageView sd_setImageWithURL:url placeholderImage:self.placeholderImage];
                //去重复给图片添加手势
                if (i <= count+2) {
                    imageView.tag = i-2;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickImageView:)];
                    [imageView addGestureRecognizer:tap];
                }
            }

            [self.scrollView addSubview:imageView];
            [arrM addObject:imageView];
        }
        _scrollerImageViews = arrM;
    }
    return _scrollerImageViews;
}
//点击代理
- (void)didClickImageView:(UITapGestureRecognizer*)tap
{
    UIImageView *imageView = (UIImageView*)tap.view;
    if ([_delegate respondsToSelector:@selector(NNScrollView:didClickImageIndex:)]) {
        [_delegate NNScrollView:self didClickImageIndex:imageView.tag];
    }
}
- (void)setSpace:(CGFloat)space
{
    _space = space;
    //如果图片大小为屏幕的大小 间距为零
    if (_imageViewW == [UIScreen mainScreen].bounds.size.width) {
        _space = 0;
    }
}
- (void)setImageViewW:(CGFloat)imageViewW
{
    _imageViewW = imageViewW;
    //如果图片大小为屏幕的大小 间距为零
    if (_imageViewW == [UIScreen mainScreen].bounds.size.width) {
        _space = 0;
    }
}
- (void)setup
{
    //scrollView
    self.scrollView = [[UIScrollView alloc]init];
    [self addSubview:self.scrollView];
    //自定义手势实现翻页效果
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changePage:)];
    [self addGestureRecognizer:pan];
    //pageControll
    self.pageControll = [[UIPageControl alloc]init];
    self.pageControll.numberOfPages = self.imagesURL.count;
    self.pageControll.pageIndicatorTintColor = [UIColor redColor];
    self.pageControll.currentPageIndicatorTintColor =[UIColor yellowColor];
    [self addSubview:self.pageControll];
    self.pageControll.userInteractionEnabled = NO;
    //默认设置
    self.space = 10;
    self.imageViewW = screenW - 100;
    kPage = 2;
    self.timerInterval = 2;
    //定时器
    kTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:kTimer forMode:NSRunLoopCommonModes];
    
}
- (void)dealloc
{
    [kTimer invalidate];
}
//下一页
- (void)nextPage
{
    kPage += 1;
    CGPoint conteOffset = self.scrollView.contentOffset;
    //当到达第二个第一页情况：
    if (kPage == kCount +2 )
    {
        //动画跳转到第二个第一页
        conteOffset.x = kPage * kStep;
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = conteOffset;
        }completion:^(BOOL finished) {
            //动画结束后直接平移到第一个第一页
            kPage = 2;
            self.scrollView.contentOffset = CGPointMake(kStep*2, 0);
        }];
    }else
    {
        conteOffset.x = kPage * kStep;
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = conteOffset;
        }];
    }
    //计算pageControll 取余目的是从零开始
    self.pageControll.currentPage = (kPage-2)%kCount;
}
//拖拽手势事件
- (void)changePage:(UIPanGestureRecognizer*)pan
{
   
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        //速度 用于观察拖到方向
        CGPoint velocity = [pan velocityInView:self];
        CGPoint conteOffset = self.scrollView.contentOffset;
        //计算用户拖拽的偏移量大小 参照与开始拖动的位置
        CGFloat translationX = kOldConteOffsetX - self.scrollView.contentOffset.x;
        //最大偏移量 判断是否要翻页
        if (fabs(translationX) < 20)
        {
            //没有翻页回退
           CGPoint contentOffset = self.scrollView.contentOffset;
            contentOffset.x += translationX;
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = contentOffset;
            }];
           [self addTimer];
          return;
        }
        //向前托
        if (velocity.x < 0)
        {
            [self nextPage];
        }
        else //向后托
        {
            kPage -= 1;
            //要跳转点，当滑到第一个最后一页：(图片数组的布局是451234512)
            if (kPage == 1 ) {
                //1.设置动画
                conteOffset.x = kPage * kStep;
                [UIView animateWithDuration:0.2 animations:^{
                    self.scrollView.contentOffset = conteOffset;
                }completion:^(BOOL finished) {
                //2.动画结束后直接平移到第二个最后一页
                    kPage = kCount+1;
                    self.scrollView.contentOffset = CGPointMake(kStep*kPage, 0);
                }];
            }else
            {//一般换页
                conteOffset.x = kPage * kStep;
                [UIView animateWithDuration:0.2 animations:^{
                    self.scrollView.contentOffset = conteOffset;
                }];
            }
            //计算pageControll下标，特殊情况
            if ((kPage-2)%kCount == -1)
                self.pageControll.currentPage = 4;
            else
                self.pageControll.currentPage = (kPage-2)%kCount;
        }
        
        //从新添加定时器
        [self addTimer];
        
    }
    if (pan.state == UIGestureRecognizerStateChanged)
    {
        //相对于view的手势移动的偏移量
        CGPoint translation = [pan translationInView:self];
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x -= translation.x*1.2;
        self.scrollView.contentOffset = contentOffset;
        [pan setTranslation:CGPointZero inView:self];
    }
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        //用于计算偏移量 小的偏移量 就不操作
        kOldConteOffsetX = self.scrollView.contentOffset.x;
        [kTimer invalidate];
    }
}
//添加定时器
- (void)addTimer
{
    kTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:kTimer forMode:NSRunLoopCommonModes];
}
//布局计算
- (void)layoutSubviews
{
    [super layoutSubviews];
    kCount = (int)self.imagesURL.count;
    self.pageControll.numberOfPages = self.imagesURL.count;
    //布局scrollView
    self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGFloat imageViewH = self.bounds.size.height;
    //计算翻页步长
    kStep = self.imageViewW + self.space;
    //默认偏移两页
    self.scrollView.contentOffset = CGPointMake(kStep*2, 0);
    //第一个imageView的originX = head + space
    CGFloat imageViewOriginX = (screenW - (self.imageViewW + self.space*2))/2 +self.space;
    //布局imageView
    for (int i = 0; i < kCount + 4; i++) {
        CGFloat imageViewX = (self.imageViewW + self.space ) * i + imageViewOriginX;
        UIImageView *imageView = self.scrollerImageViews[i];
        imageView.frame = CGRectMake(imageViewX, 0, self.imageViewW, imageViewH);
    }
    //布局pageControll
    self.pageControll.frame = CGRectMake(0, 0, 100, 50);
    self.pageControll.center = CGPointMake(screenW/2, imageViewH-20);
}

@end
