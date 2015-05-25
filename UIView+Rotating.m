//
//  UIView+Rotating.m
//
//  Created by HuangCharlie on 2/7/15.
//  Copyright (c) 2015 HuangCharlie. All rights reserved.
//

#import "UIView+Rotating.h"
#import <objc/runtime.h>



@implementation UIView (Rotatable)


-(void)setOldTransform:(NSValue *)oldTransform
{
    objc_setAssociatedObject(self, @selector(oldTransform), oldTransform, OBJC_ASSOCIATION_RETAIN);
}

-(NSValue*)oldTransform
{
    return objc_getAssociatedObject(self, @selector(oldTransform));
}


-(void)setRotateGesture:(UIRotationGestureRecognizer *)rotateGesture
{
    objc_setAssociatedObject(self, @selector(rotateGesture), rotateGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIRotationGestureRecognizer*)rotateGesture
{
    return objc_getAssociatedObject(self, @selector(rotateGesture));
}


-(void)setViewRotatable
{
    self.rotateGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotation:)];
    self.rotateGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.rotateGesture];
    
    self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
}

-(void)setRotationEnabled:(BOOL)enable
{
    [self.rotateGesture setEnabled:enable];
}

-(void)handleRotation:(UIRotationGestureRecognizer*)sender
{
    //用core graph里面封装好的CGAffineTransformScale做rotate变换
    CGFloat rotate = [sender rotation];
    
    if(self.rotateGesture.state == UIGestureRecognizerStateChanged)
    {
        //因为每次获取的tran属性不能叠加（本方法会被不断调用），故使用现有的方法，利用已经实现的transform属性来实现新的transform
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformRotate(old, rotate);
    }
    else if(self.rotateGesture.state == UIGestureRecognizerStateEnded)
    {
        //保存已经实现好的transform，该属性与rotate，resize共用
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformRotate(old, rotate);
        self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
    }
}

@end
