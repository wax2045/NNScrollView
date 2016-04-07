//
//  NNScrollView.h
//  xuanHuanGunDong
//
//  Created by mac on 16/4/5.
//  Copyright © 2016年 HYJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - NNScrollViewDelegate
@class NNScrollView;
@protocol NNScrollViewDelegate <NSObject>
//代理点击了数组里的那个图片下标
- (void)NNScrollView:(NNScrollView*)scrollView didClickImageIndex:(NSInteger)index;
@end

@interface NNScrollView : UIView
//图片间间距
@property (nonatomic,assign) CGFloat space;
//图片大小
@property (nonatomic,assign) CGFloat imageViewW;
//图片URL数组
@property (nonatomic, strong) NSArray *imagesURL;
//占位图 用于网络加载图片
@property (nonatomic, strong) UIImage *placeholderImage;
//定时器间隔时间
@property (nonatomic, assign) CGFloat timerInterval;
@property (nonatomic, weak) id<NNScrollViewDelegate>delegate;
@end
