@interface SBPowerDownController : UIViewController
-(void)cancel;
-(void)powerDown;
@end

@interface SpringBoard : UIApplication
+(id)sharedApplication;
-(SBPowerDownController *)powerDownController;
@end

@interface FBSystemService : NSObject
+(id)sharedInstance;
-(void)shutdownAndReboot:(BOOL)arg1;
@end

bool isActive = false;

%hook SBPowerDownController

%new
- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_y = location.y - previousLocation.y;
    
    if (!(button.center.x < (self.view.frame.size.width/2)))
    {
        if (!(button.center.y > 552))
        {
            if (!(button.center.y < 190))
            {
                button.center = CGPointMake(207, button.center.y + delta_y);
                
                if (button.center.y < 240)
                {
                     [[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot:1];
                }
                
                if (button.center.y > 507)
                {
                    [self powerDown];
                }
            }
        }
        
    }
}

-(void)orderFront{
    %orig;
    
    isActive = true;
    
    
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    // Dim code
    
    UIView *dimRec = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [dimRec setBackgroundColor:[UIColor blackColor]];
    dimRec.alpha = 0.4;
    
    //Button Code
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     [button addTarget: self action: @selector(wasDragged: withEvent:) forControlEvents: UIControlEventTouchDragInside];
    
    [button setBackgroundColor:[UIColor whiteColor]];
    button.frame = CGRectMake((self.view.frame.size.width/2) - 50, (self.view.frame.size.height/2) - 50, 100, 100);
    button.layer.cornerRadius = 100/2;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowRadius = 1;
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"borderColor"];
    anim.values = [NSArray arrayWithObjects: (id)[UIColor greenColor].CGColor,
                   (id)[UIColor yellowColor].CGColor, (id)[UIColor orangeColor].CGColor, (id)[UIColor redColor].CGColor,  (id)[UIColor cyanColor].CGColor, nil];
    anim.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.25], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.75],[NSNumber numberWithFloat:1.0], nil];
    anim.calculationMode = kCAAnimationPaced;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.duration = 8.0f;
    anim.repeatCount = HUGE;
    button.layer.borderColor = [[UIColor cyanColor] CGColor];
    [button.layer addAnimation:anim forKey:nil];
    button.layer.borderWidth = 2.3;
    
    //Slide Down Thing
    UIView *downSlider = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 50, (self.view.frame.size.height/2) - 35, 100, 250)];
    [downSlider setBackgroundColor:[UIColor whiteColor]];
    downSlider.layer.cornerRadius = 100/2;
    downSlider.alpha = 0.9;
    downSlider.layer.borderColor = [[UIColor redColor] CGColor];
    downSlider.layer.borderWidth = 2;
    
    
    //Slide Up Thing
    UIView *upSlider = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 50, (self.view.frame.size.height/2) + 35, 100, -250)];
    [upSlider setBackgroundColor:[UIColor whiteColor]];
    upSlider.layer.cornerRadius = 100/2;
    upSlider.alpha = 0.9;
    upSlider.layer.borderColor = [[UIColor yellowColor] CGColor];
    upSlider.layer.borderWidth = 2;
    
    //Label Ting
    UILabel *rebootLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 30, (self.view.frame.size.height/2) - 120, 100, -250)];
    rebootLabel.adjustsFontSizeToFitWidth = TRUE;
    rebootLabel.text = @"Reboot";
    [rebootLabel setTextColor:[UIColor yellowColor]];
    rebootLabel.backgroundColor = [UIColor clearColor];
    
    //Other Label Ting
    UILabel *shutdownLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - 40, (self.view.frame.size.height/2) + 370, 100, -250)];
    shutdownLabel.adjustsFontSizeToFitWidth = TRUE;
    shutdownLabel.text = @"Shutdown";
    [shutdownLabel setTextColor:[UIColor redColor]];
    shutdownLabel.backgroundColor = [UIColor clearColor];
    
    
    //Finish View Shiz
    [self.view addSubview:dimRec];
    [self.view addSubview:upSlider];
    [self.view addSubview:downSlider];
    [self.view addSubview:rebootLabel];
    [self.view addSubview:shutdownLabel];
    [self.view addSubview:button];
    
    
}
%end


%hook SBHomeHardwareButton
-(void)singlePressUp:(id)arg1 {
    if (isActive == true)
    {
        isActive = false;
        [[[%c(SpringBoard) sharedApplication] powerDownController] cancel];
    } else {
        %orig(arg1);
    }
}

%end
