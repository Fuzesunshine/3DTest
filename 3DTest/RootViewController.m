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
    
    UIImageView *img1;
    UIImageView *img2;
    UIImageView *img3;
    UIImageView *img4;
    UIImageView *img0;
    
    NSArray *pictureNames;
    NSMutableArray *imgViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pictureNames = @[@"image01.JPG", @"image02.JPG", @"image03.JPG", @"image04.JPG", @"image05.JPG"];
    imgViews = [[NSMutableArray alloc]init];
    UIView *touchView = [[UIView alloc]initWithFrame:CGRectMake(0, 384, 1024, 384)];
    touchView.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:touchView];
    
    [self initPictures];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAllHandle:)];
    [self.view addGestureRecognizer:panGesture];
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
        CGFloat percent = M_PI / (6*287);
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0.01;
        NSLog(@"%f, %lu",location.x, (unsigned long)num);
        POPBasicAnimation *moveAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        moveAnimation.duration = 0.01;
        
        if ((location.x-num)>300) {
            rotationAnimation.toValue = @(-(300)*percent+M_PI/6);
            moveAnimation.toValue = @(300+initialLocation);
        } else if ((location.x-num)<-300) {
            rotationAnimation.toValue = @(-(-300)*percent+M_PI/6);
            moveAnimation.toValue = @(-300+initialLocation);
        } else {
            rotationAnimation.toValue = @(-(location.x-num)*percent+M_PI/6);
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
            if ((location.x-num)>287) {
                initialLocation = 287+initialLocation;
                recoverAnimation.toValue = @(0);
            } else if ((location.x-num)<-200) {
                initialLocation = -200+initialLocation;
                recoverAnimation.toValue = @(M_PI/4);
            } else {
                recoverAnimation.toValue = @(M_PI/6);
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

- (void)showImageAndReflection:(UIImageView *)view {
    // 制作reflection
    CALayer *layer = view.layer;
    CALayer *reflectLayer = [CALayer layer];
    reflectLayer.contents = layer.contents;
    reflectLayer.bounds = layer.bounds;
    reflectLayer.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height*1.5);
    reflectLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    
    // 给该reflection加个半透明的layer
    CALayer *blackLayer = [CALayer layer];
    blackLayer.backgroundColor = [UIColor whiteColor].CGColor;
    blackLayer.bounds = reflectLayer.bounds;
    blackLayer.position = CGPointMake(blackLayer.bounds.size.width/2, blackLayer.bounds.size.height/2);
    blackLayer.opacity = 0.6;
    [reflectLayer addSublayer:blackLayer];
    
    // 给该reflection加个mask
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.bounds = reflectLayer.bounds;
    mask.position = CGPointMake(mask.bounds.size.width/2, mask.bounds.size.height/2);
    mask.colors = [NSArray arrayWithObjects:
                   (__bridge id)[UIColor clearColor].CGColor,
                   (__bridge id)[UIColor whiteColor].CGColor, nil];
//    mask.colors = [NSArray arrayWithObjects:
//                   (__bridge id)[UIColor clearColor].CGColor,
//                    nil];
    mask.startPoint = CGPointMake(0.5, 0.65);
    mask.endPoint = CGPointMake(0.5, 1);
    reflectLayer.mask = mask;
    
    // 作为layer的sublayer
    [layer addSublayer:reflectLayer];
    // 加入UICoverFlowView的sublayers
//    UIView *reView =[[UIView alloc]init];
//    reView.bounds = layer.bounds;
//    [view.layer addSublayer:layer];
}

- (void)initPictures {
    for (int i = 0; i<5; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[pictureNames objectAtIndex:i]]];
        imgView.frame = CGRectMake(0, 0, 319, 187);
        imgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        imgView.layer.anchorPointZ = 100.0f;
        imgView.layer.position = CGPointMake(-62+i*287, 374/4+30);
        imgView.layer.transform = [self setTransform3D];
//        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.userInteractionEnabled = YES;
        
        POPBasicAnimation *initRotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        initRotationAnimation.duration = 0;
        initRotationAnimation.toValue = @((2-i)*M_PI/6);
        
        [imgView.layer pop_addAnimation:initRotationAnimation forKey:@"initRotation"];
        
        [self showImageAndReflection:imgView];
        
        [imgViews addObject:imgView];
        [self.view addSubview:imgView];
    }
}

- (void)panAllHandle:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        num = location.x;
    }
    NSMutableArray *rotationAnimations = [[NSMutableArray alloc]init];
    NSMutableArray *moveAnimations = [[NSMutableArray alloc]init];
    
    NSMutableArray *rotationEndAnimations = [[NSMutableArray alloc]init];
    NSMutableArray *moveEndAnimations = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<5; i++) {
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0.01;
        POPBasicAnimation *moveAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        moveAnimation.duration = 0.01;
        
        [rotationAnimations addObject:rotationAnimation];
        [moveAnimations addObject:moveAnimation];
    }
    if (YES) {
        CGFloat percent = M_PI / (6*287);
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0.01;
        NSLog(@"%f, %lu",location.x, (unsigned long)num);
        POPBasicAnimation *moveAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        moveAnimation.duration = 0.01;
        
        if ((location.x-num)>400) {
            for (int i = 0; i<4; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(400)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(400-62+i*287);
                
                UIImageView *imgView = [imgViews objectAtIndex:i];
                [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                [imgView.layer pop_addAnimation:move forKey:@"move"];
            }
        } else if ((location.x-num)<-400) {
            for (int i = 1; i<5; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(-400)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(-400-62+i*287);
                
                UIImageView *imgView = [imgViews objectAtIndex:i];
                [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                [imgView.layer pop_addAnimation:move forKey:@"move"];
            }
        } else if ((location.x - num)>0) {
            for (int i = 0; i<4; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(location.x-num)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(location.x-num-62+i*287);
                
                UIImageView *imgView = [imgViews objectAtIndex:i];
                [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                [imgView.layer pop_addAnimation:move forKey:@"move"];
            }
        } else if ((location.x - num)<=0) {
            for (int i = 1; i<5; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(location.x-num)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(location.x-num-62+i*287);
                
                UIImageView *imgView = [imgViews objectAtIndex:i];
                [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                [imgView.layer pop_addAnimation:move forKey:@"move"];
            }
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            for (int i = 0; i<5; i++) {
                POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                recoverAnimation.springBounciness = 18.0f;
                recoverAnimation.dynamicsMass = 2.0f;
                recoverAnimation.dynamicsTension = 200;
                
                POPSpringAnimation *recover = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
                recover.springBounciness = 18.0f;
                recover.dynamicsMass = 2.0f;
                recover.dynamicsTension = 200;
                
                [rotationEndAnimations addObject:recoverAnimation];
                [moveEndAnimations addObject:recover];
            }
            
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f;
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            
            //            initialLocation = -img.frame.origin.x-img.frame.size.width/2;
            if ((location.x-num)>100) {
                for (int i = 0; i<4; i++) {
                    POPBasicAnimation *rotation = [rotationEndAnimations objectAtIndex:i];
                    rotation.toValue = @(-(287)*percent+(2-i)*M_PI/6);
                    POPBasicAnimation *move = [moveEndAnimations objectAtIndex:i];
                    move.toValue = @(287-62+i*287);
                    
                    UIImageView *imgView = [imgViews objectAtIndex:i];
                    [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                    [imgView.layer pop_addAnimation:move forKey:@"move"];
                }
                [self moveRight];
                
            } else if ((location.x-num)<-100) {
                for (int i = 1; i<5; i++) {
                    POPBasicAnimation *rotation = [rotationEndAnimations objectAtIndex:i];
                    rotation.toValue = @(-(-287)*percent+(2-i)*M_PI/6);
                    POPBasicAnimation *move = [moveEndAnimations objectAtIndex:i];
                    move.toValue = @(-287-62+i*287);
                    
                    UIImageView *imgView = [imgViews objectAtIndex:i];
                    [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                    [imgView.layer pop_addAnimation:move forKey:@"move"];
                }
                [self moveLeft];
                
            } else {
                for (int i = 0; i<5; i++) {
                    POPBasicAnimation *rotation = [rotationEndAnimations objectAtIndex:i];
                    rotation.toValue = @((2-i)*M_PI/6);
                    POPBasicAnimation *move = [moveEndAnimations objectAtIndex:i];
                    move.toValue = @(-62+i*287);
                    
                    UIImageView *imgView = [imgViews objectAtIndex:i];
                    [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                    [imgView.layer pop_addAnimation:move forKey:@"move"];
                }
            }
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
    //     }
    
    
    recognizer.enabled = YES;
}

- (void)moveRight {
    NSMutableArray *imgs = [[NSMutableArray alloc]init];
    UIImageView *imgtest = [imgViews objectAtIndex:4];
    [imgtest setHidden:YES];
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:imgtest.image];
    imgView.frame = CGRectMake(0, 0, 319, 187);
    imgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    imgView.layer.anchorPointZ = 100.0f;
    imgView.layer.position = CGPointMake(-62, 374/4+30);
    imgView.layer.transform = [self setTransform3D];
    //        imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.userInteractionEnabled = YES;
    
    POPBasicAnimation *initRotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
    initRotationAnimation.duration = 0;
    initRotationAnimation.toValue = @((2)*M_PI/6);
    
    [imgView.layer pop_addAnimation:initRotationAnimation forKey:@"initRotation"];
    
    [self showImageAndReflection:imgView];
    
    [imgs addObject:imgView];
    
    [imgtest removeFromSuperview];
    [self.view addSubview:imgView];
    
    for (int i = 0; i<4; i++) {
        [imgs addObject:[imgViews objectAtIndex:i]];
    }
    
    imgViews = imgs;
}

- (void)moveLeft {
    NSMutableArray *imgs = [[NSMutableArray alloc]init];
    UIImageView *imgtest = [imgViews objectAtIndex:0];
    [imgtest setHidden:YES];
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:imgtest.image];
    imgView.frame = CGRectMake(0, 0, 319, 187);
    imgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    imgView.layer.anchorPointZ = 100.0f;
    imgView.layer.position = CGPointMake(-62+4*287, 374/4+30);
    imgView.layer.transform = [self setTransform3D];
    //        imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.userInteractionEnabled = YES;
    
    POPBasicAnimation *initRotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
    initRotationAnimation.duration = 0;
    initRotationAnimation.toValue = @((-2)*M_PI/6);
    
    [imgView.layer pop_addAnimation:initRotationAnimation forKey:@"initRotation"];
    
    [self showImageAndReflection:imgView];
    
    for (int i = 1; i<5; i++) {
        [imgs addObject:[imgViews objectAtIndex:i]];
    }
    
    [imgs addObject:imgView];
    [imgtest removeFromSuperview];
    [self.view addSubview:imgView];
    imgViews = imgs;
}

@end
