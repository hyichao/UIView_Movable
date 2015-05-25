//
//  UIView+Dragging.h
//
//  Created by HuangCharlie on 2/9/15.
//  Copyright (c) 2015 HuangCharlie. All rights reserved.
//
typedef void (^DraggableOutOfView) (int dir);//1:top 2:bottom 3:left 4: right


#import <UIKit/UIKit.h>


@protocol DraggingDelegate <NSObject>

@optional
- (void)draggableOutOfView:(int)dir;
@end

@interface UIView (Dragging)

@property (nonatomic) UIPanGestureRecognizer* panGesture;

@property (nonatomic) NSValue* oldTransform;

@property (nonatomic) NSValue* original;

@property (nonatomic) NSValue* maxArea;

@property(nonatomic) id<DraggingDelegate> actionDelegate;


-(void)setViewDraggable;

-(void)setDraggingEnabled:(BOOL)enable;

-(void)setDraggableInView:(CGSize)size;

@end
