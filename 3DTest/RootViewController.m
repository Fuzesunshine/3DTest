//
//  RootViewController.m
//  3DTest
//
//  Created by fuze on 16/7/25.
//  Copyright © 2016年 fuze. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController {
    UIImageView *img;
    NSUInteger initialLocation;
    NSUInteger num;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"aa.jpg"]];
    img.frame = CGRectMake(0, 0, 774/2, 300);
    
    img.layer.anchorPoint = CGPointMake(0.5, 0.5);
    img.layer.anchorPointZ = 200.0f;
    img.layer.position = CGPointMake(774/4, 150);
    initialLocation = 774/4;
    img.layer.transform = [self setTransform3D];
    
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    [self.view addGestureRecognizer:panGesture];
    
    [self.view addSubview:img];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(CATransform3D)setTransform3D{
    //如果不设置这个值，无论转多少角度都不会有3D效果
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}

-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.x > 0 && location.x < view.bounds.size.width) &&
        (location.y > 0 && location.y < view.bounds.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

- (void)panHandle:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        num = location.x;
    }
    
    if (YES) {
        CGFloat percent = M_PI / 800;
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0.01;
        NSLog(@"%f, %lu",location.x, (unsigned long)num);
        POPBasicAnimation *moveAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        moveAnimation.duration = 0.01;
        
        if ((location.x-num)>250) {
            rotationAnimation.toValue = @(-(250)*percent);
            moveAnimation.toValue = @(250+initialLocation);
        } else if ((location.x-num)<-250) {
            rotationAnimation.toValue = @(-(-250)*percent);
            moveAnimation.toValue = @(-250+initialLocation);
        } else {
            rotationAnimation.toValue = @(-(location.x-num)*percent);
            moveAnimation.toValue = @(location.x-num+initialLocation);
        }
        [img.layer pop_addAnimation:moveAnimation forKey:@"moveAnimation"];
        [img.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f;
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            
//            initialLocation = -img.frame.origin.x-img.frame.size.width/2;
            if ((location.x-num)>200) {
                initialLocation = 200+initialLocation;
                recoverAnimation.toValue = @(-M_PI/4);
            } else if ((location.x-num)<-200) {
                initialLocation = -200+initialLocation;
                recoverAnimation.toValue = @(M_PI/4);
            } else {
                recoverAnimation.toValue = @(0);
            }
            
            POPSpringAnimation *recover = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            recover.springBounciness = 18.0f;
            recover.dynamicsMass = 2.0f;
            recover.dynamicsTension = 200;
            recover.toValue = @(initialLocation);
            [img.layer pop_addAnimation:recover forKey:@"recover"];
            [img.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
            
            NSLog(@"%lu", (unsigned long)initialLocation);
//            img.frame = CGRectMake(0, +location.x-initialLocation, 774/2, 300);
        }
    }
    
//    if (location.y < 0 || location.y>(CGRectGetWidth(img.bounds))) {
//        recognizer.enabled = NO;
//        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
//        recoverAnimation.springBounciness = 18.0f;
//        recoverAnimation.dynamicsMass = 2.0f;
//        recoverAnimation.dynamicsTension = 200;
//        recoverAnimation.toValue = @(0);
//        [img.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
//    }
    
    recognizer.enabled = YES;
}

@end
