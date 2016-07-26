#制作POP翻页动画
我利用了POP库制作了简单的广告展示的翻页效果：
![Markdown](https://github.com/Fuzesunshine/3DTest/yanshi.gif)
**源码在[这里](https://github.com/Fuzesunshine/3DTest)**
## 大致思路
首先简单分析一下动画效果：
我们使用了旋转以及平移两个动画效果，通过动图可以看到：通过手指拖动(pan)，图片在平移的同时绕着自身中轴线旋转。
<!--more-->
那么怎么让图片绕着中轴线旋转呢？可以使用*POPBasicAnimation*中的*kPOPLayerRotaionY*制作旋转动画，中轴线的位置为锚点的位置，可以通过*anchorPoint*、*anchorPointZ*以及*position*共同确定锚点的三维坐标。至于*anchorPoint*与*position*如何共同确定绝对坐标可以参照**[博客](http://wonderffee.github.io/blog/2013/10/13/understand-anchorpoint-and-position/)**，简单来说：锚点是标志一个layer位置的点，*anchorPoint*是锚点在该layer的相对坐标，而*positon*是锚点在superView中的绝对坐标。
沿x轴的平移效果可以通过*POPBasicAnimaition*的*kPOPLayerPositionX*来实现。**旋转的角度以及平移的距离都与手指拖动(pan)的距离有关**。
## 源码分析
首先初始化五张图片，设置不同的位置，以及不同的旋转角度。在画面中只显示3张，但为了左右拖动时有图片补位，这里初始化5张。

```objective-c
- (void)initPictures {
    for (int i = 0; i<5; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[pictureNames objectAtIndex:i]]];
        imgView.frame = CGRectMake(0, 0, 319, 187);
        imgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        imgView.layer.anchorPointZ = 100.0f;
        imgView.layer.position = CGPointMake(-62+i*287, 374/4+30);
        imgView.layer.transform = [self setTransform3D];
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
```
这里通过*showImageAndReflection*函数来设置图片的倒影：

```objective-c
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
    mask.startPoint = CGPointMake(0.5, 0.65);
    mask.endPoint = CGPointMake(0.5, 1);
    reflectLayer.mask = mask;
    
    // 作为layer的sublayer
    [layer addSublayer:reflectLayer];
}
```
代码参考**[这里](http://www.programgo.com/article/76012388626/)**

随后设置拖动手势*UIPanGestureRecognizer*并绑定*panAllHandle*函数，将手势绑定在当前view上。

```objective-c
UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAllHandle:)];
[self.view addGestureRecognizer:panGesture];
```
处理函数*panAllHandle*为：

```objective-c
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
        
        if ((location.x-num)>350) {
            for (int i = 0; i<4; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(350)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(350-62+i*287);
                
                UIImageView *imgView = [imgViews objectAtIndex:i];
                [imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
                [imgView.layer pop_addAnimation:move forKey:@"move"];
            }
        } else if ((location.x-num)<-350) {
            for (int i = 1; i<5; i++) {
                POPBasicAnimation *rotation = [rotationAnimations objectAtIndex:i];
                rotation.toValue = @(-(-350)*percent+(2-i)*M_PI/6);
                POPBasicAnimation *move = [moveAnimations objectAtIndex:i];
                move.toValue = @(-350-62+i*287);
                
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
            if ((location.x-num)>50) {
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
                
            } else if ((location.x-num)<-50) {
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
}
```
由于重复的动画过多，这里只解释其中两种：
初始化旋转以及平移函数,*duration*代表持续时间。

```objective-c
POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
rotationAnimation.duration = 0.01;
POPBasicAnimation *moveAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
moveAnimation.duration = 0.01;
```

通过*position.x*与*num*的差值，获得拖动的x轴方向距离。根据该距离设置好旋转动画旋转的角度，以及平移动画平移的距离。

```objective-c 
rotation.toValue = @(-(location.x-num)*percent+(2-i)*M_PI/6);
move.toValue = @(location.x-num-62+i*287);
```
最后将动画绑定在图片上：

```objective-c
[imgView.layer pop_addAnimation:rotation forKey:@"rotation"];
[imgView.layer pop_addAnimation:move forKey:@"move"];
```
这样一个图片的动画就完成了。最后推广在到所有图片上，并为拖动距离添加一定的阈值即可完成动画。


