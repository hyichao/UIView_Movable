//
//  UIView+Dragging.m
//
//  Created by HuangCharlie on 2/9/15.
//  Copyright (c) 2015 HuangCharlie. All rights reserved.
//

#import "UIView+Dragging.h"
#import <objc/runtime.h>


@implementation UIView (Dragging)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setOldTransform:(NSValue *)oldTransform
{
    objc_setAssociatedObject(self, @selector(oldTransform), oldTransform, OBJC_ASSOCIATION_RETAIN);
}

-(NSValue*)oldTransform
{
    return objc_getAssociatedObject(self, @selector(oldTransform));
}

-(void)setOriginal:(NSValue *)original{
    objc_setAssociatedObject(self, @selector(original), original, OBJC_ASSOCIATION_RETAIN);
}
-(NSValue*)original{
    return objc_getAssociatedObject(self, @selector(original));
}

-(void)setMaxArea:(NSValue *)maxArea{
    objc_setAssociatedObject(self, @selector(maxArea), maxArea, OBJC_ASSOCIATION_RETAIN);
}
-(NSValue*)maxArea{
    return objc_getAssociatedObject(self, @selector(maxArea));
}


-(void)setPanGesture:(UIPanGestureRecognizer *)panGesture
{
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}


-(void)setActionDelegate:(id<DraggingDelegate>)actionDelegate{
     objc_setAssociatedObject(self, @selector(actionDelegate), actionDelegate, OBJC_ASSOCIATION_ASSIGN);
}
-(id<DraggingDelegate>)actionDelegate{
    
    return objc_getAssociatedObject(self, @selector(actionDelegate));
}
- (UIPinchGestureRecognizer*)panGesture
{
    return objc_getAssociatedObject(self, @selector(panGesture));
}


-(void)setViewDraggable
{
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleDrag:)];
    self.panGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.panGesture];
    
    self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
}
-(void)setDraggableInView:(CGSize)size;{
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewDragInView:)];
    self.panGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.panGesture];
    
    self.original  = [NSValue valueWithCGPoint:self.frame.origin];
    self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
    self.maxArea =  [NSValue valueWithCGSize:size];
}
-(void)setDraggingEnabled:(BOOL)enable
{
    [self.panGesture setEnabled:enable];
}
-(void)judgeIsOutView{
    
}
-(void)viewDragInView:(UIPanGestureRecognizer*)sender{
    CGPoint tran = [sender translationInView:self];
    CGPoint originPoint = [self.original CGPointValue];
    CGSize area = [self.maxArea CGSizeValue];
    area.width  -= self.frame.size.width;
    area.height -= self.frame.size.height;
    if(self.panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        CGAffineTransform new = CGAffineTransformTranslate(old, tran.x, tran.y);
         CGFloat padY = new.ty +originPoint.y;
         CGFloat padX = new.tx +originPoint.x;

        if (padY<0||padX<0||padY>area.height||padX>area.width) {
            int dir = 0;
            if (padY<0) {
                dir = 1;
                new.ty -= padY;
            }else if(padY>area.height){
                dir = 2;
                new.ty -= padY - area.height;
            }
            if (padX<0){
                dir = 3;
                new.tx -= padX;
            }else if(padX>area.width){
                dir = 4;
                new.tx -= padX - area.width;
            }
            
            self.transform = new;
            if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(draggableOutOfView:)])
            {
                  [self.actionDelegate draggableOutOfView:dir];
            }
            
            return;
        }
        self.transform = CGAffineTransformTranslate(old, tran.x, tran.y);

    }
    else if(self.panGesture.state == UIGestureRecognizerStateEnded)
    {
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        CGAffineTransform new = CGAffineTransformTranslate(old, tran.x, tran.y);
        CGFloat padY = new.ty +originPoint.y;
        CGFloat padX = new.tx +originPoint.x;
        if (padY<0||padX<0||padY>area.height||padX>area.width) {
            int dir = 0;
            if (padY<0) {
                dir = 1;
                new.ty -= padY;
            }else if(padY>area.height){
                dir = 2;
                new.ty -= padY - area.height;
            }
            if (padX<0){
                dir = 3;
                new.tx -= padX;
            }else if(padX>area.width){
                dir = 4;
                new.tx -= padX - area.width;
            }
            
            self.transform = new;
//            [self.actionDelegate draggableOutOfView:dir];
            self.transform = new;
            self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
            return;
        }
        self.transform = CGAffineTransformTranslate(old, tran.x, tran.y);
        self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
    }
}
-(void)handleDrag:(id)sender
{
    CGPoint tran = [sender translationInView:self];

    if(self.panGesture.state == UIGestureRecognizerStateChanged)
    {
        //因为每次获取的tran属性不能叠加（本方法会被不断调用），故使用现有的方法，利用已经实现的transform属性来实现新的transform
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformTranslate(old, tran.x, tran.y);
    }
    else if(self.panGesture.state == UIGestureRecognizerStateEnded)
    {
        //保存已经实现好的transform，该属性与rotate，resize共用
        CGAffineTransform old = [self.oldTransform CGAffineTransformValue];
        self.transform = CGAffineTransformTranslate(old, tran.x, tran.y);
        self.oldTransform = [NSValue valueWithCGAffineTransform:self.transform];
    }
}

@end
