//
//  UIView+Resizing.h
//
//  Created by HuangCharlie on 2/7/15.
//  Copyright (c) 2015 HuangCharlie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Resizing)

@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic) NSValue* oldTransform;

-(void)setViewResizable;

-(void)setResizingEnabled:(BOOL)enable;


@end
