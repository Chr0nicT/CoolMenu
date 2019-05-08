#include <spawn.h>

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
- (void)shutdownPressed:(UIButton *)btn {
     [self powerDown];
}

%new
- (void)rebootPressed:(UIButton *)btn {
     [[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot:1];
}

%new
- (void)respringPressed:(UIButton *)btn {
     pid_t pid;
     int status;
     const char* args[] = {"killall", "-9", "SpringBoard", NULL};
     posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}

%new
- (void)safemodePressed:(UIButton *)btn {
     pid_t pid;
     int status;
     const char* args[] = {"killall", "-11", "SpringBoard", NULL};
     posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}

-(void)orderFront{
    %orig;
    
    isActive = true;
    
    
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    // Dim code
    
    UIView *dimRec = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [dimRec setBackgroundColor:[UIColor blackColor]];
    dimRec.alpha = 0.4;
    
    // Reboot Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f]];

    button.frame = CGRectMake((self.view.frame.size.width/2) - 100, (self.view.frame.size.height/2) - 190, 200, 300);
    button.layer.cornerRadius = 20;
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
    button.layer.borderWidth = 3;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [button setTransform:CGAffineTransformScale([button transform], 1.3, 1.2)];
    [UIView commitAnimations];

    
    //Shutdown Slider
    UIButton *shutdownSlider = [UIButton buttonWithType:UIButtonTypeCustom];
    [shutdownSlider setBackgroundColor:[UIColor colorWithRed:232.0/255.0 green:53.0/255.0 blue:86.0/255.0 alpha:1]];
    
    [shutdownSlider setTitle:@"Shutdown" forState:UIControlStateNormal];
    [shutdownSlider setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    
    shutdownSlider.frame = CGRectMake((self.view.frame.size.width/2) - 100, (self.view.frame.size.height/2) - 190, 200, 50);
    shutdownSlider.layer.cornerRadius = 20;
    shutdownSlider.layer.shadowOffset = CGSizeMake(0, 1);
    shutdownSlider.layer.shadowOpacity = 0.5;
    shutdownSlider.layer.shadowRadius = 1;

    [button addTarget:self action:@selector(shutdownPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    //Reboot Slider
    UIButton *rebootSlider = [UIButton buttonWithType:UIButtonTypeCustom];
    [rebootSlider setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:235.0/255.0 blue:118.0/255.0 alpha:1]];
    
    [rebootSlider setTitle:@"Reboot" forState:UIControlStateNormal];
    [rebootSlider setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    
    [rebootSlider addTarget:self action:@selector(rebootPressed:)
     forControlEvents:UIControlEventTouchUpInside];

    
    rebootSlider.frame = CGRectMake((self.view.frame.size.width/2) - 100, (self.view.frame.size.height/2) - 112, 200, 50);
    rebootSlider.layer.cornerRadius = 20;
    rebootSlider.layer.shadowOffset = CGSizeMake(0, 1);
    rebootSlider.layer.shadowOpacity = 0.5;
    rebootSlider.layer.shadowRadius = 1;
    
    //Respring Slider
    UIButton *respringSlider = [UIButton buttonWithType:UIButtonTypeCustom];
    [respringSlider setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:136.0/255.0 blue:24.0/255.0 alpha:1]];
    
    [respringSlider setTitle:@"Respring" forState:UIControlStateNormal];
    [respringSlider setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    
    [respringSlider addTarget:self action:@selector(respringPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    respringSlider.frame = CGRectMake((self.view.frame.size.width/2) - 100, (self.view.frame.size.height/2) - 35, 200, 50);
    respringSlider.layer.cornerRadius = 20;
    respringSlider.layer.shadowOffset = CGSizeMake(0, 1);
    respringSlider.layer.shadowOpacity = 0.5;
    respringSlider.layer.shadowRadius = 1;
    
    //Safemode Slider
    UIButton *safeSlider = [UIButton buttonWithType:UIButtonTypeCustom];
    [safeSlider setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:220.0/255.0 blue:237.0/255.0 alpha:1]];
    
    [safeSlider setTitle:@"Safemode" forState:UIControlStateNormal];
    [safeSlider setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f] forState:UIControlStateNormal];
    
    [safeSlider addTarget:self action:@selector(safemodePressed:)
     forControlEvents:UIControlEventTouchUpInside];

    safeSlider.frame = CGRectMake((self.view.frame.size.width/2) - 100, (self.view.frame.size.height/2) + 50, 200, 50);
    safeSlider.layer.cornerRadius = 20;
    safeSlider.layer.shadowOffset = CGSizeMake(0, 1);
    safeSlider.layer.shadowOpacity = 0.5;
    safeSlider.layer.shadowRadius = 1;
    
    [self.view addSubview:dimRec];
    [self.view addSubview:button];
    [self.view addSubview:shutdownSlider];
    [self.view addSubview:rebootSlider];
    [self.view addSubview:respringSlider];
    [self.view addSubview:safeSlider];
    
    
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
