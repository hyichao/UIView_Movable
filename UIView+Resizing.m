//
//  UIView+Resizing.m
//
//  Created by HuangCharlie on 2/7/15.
//  Copyright (c) 2015 HuangCharlie. All rights reserved.
//

#import "UIView+Resizing.h"
#import <objc/runtime.h>


@implementation UIView (Resizing)

-(void)setOldTransform:(NSValue *)oldTransform
{
    objc_setAssociatedObject(self, @selector(oldTransform), oldTransform, OBJC_ASSOCIATION_RETAIN);
}

-(NSValue*)oldTransform
{
    return objc_getAssociatedObject(self, @selector(oldTransform));
}



-(void)setPinchGesture:(UIPinchGestureRecognizer *)pinchGesture
{
    objc_setAssociatedObject(self, @selector(pinchGesture), pinchGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPinchGestureRecognizer*)pinchGesture
{
    return objc_getAssociatedObject(self, @selector(pinchGesture));
}


-(void)setViewResizable
{
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handleResize:)];
    self.pinchGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.pinchGesture];
    
    self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
}

-(void)setResizingEnabled:(BOOL)enable
{
    [self.pinchGesture setEnabled:enable];
}

-(void)handleResize:(UIPinchGestureRecognizer*)sender
{
    //用core graph里面封装好的CGAffineTransformScale做scale变换
    CGFloat scale = [sender scale];
    
    if(self.pinchGesture.state == UIGestureRecognizerStateChanged)
    {
        //因为每次获取的tran属性不能叠加（本方法会被不断调用），故使用现有的方法，利用已经实现的transform属性来实现新的transform
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformScale(old, scale,scale);
    }
    else if(self.pinchGesture.state == UIGestureRecognizerStateEnded)
    {
        //保存已经实现好的transform，该属性与rotate，resize共用
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformScale(old, scale,scale);
        
        if(self.transform.a < 0.75 || self.transform.d < 0.75)
        {
            self.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
        }
        
        self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
    }
}


@end
