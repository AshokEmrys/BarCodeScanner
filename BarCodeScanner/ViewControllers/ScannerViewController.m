//
//  ScannerViewController.m
//  BarCodeScanner
//
//  Created by ParokshaX on 06/01/16.
//  Copyright © 2016 ParokshaX. All rights reserved.
//

#import "ScannerViewController.h"
#import "MBProgressHUD.h"

@interface ScannerViewController ()

@property(nonatomic) BOOL isScanEnabled;
@property(nonatomic) CAShapeLayer *scanLine;
@property (weak, nonatomic) IBOutlet UILabel *tapToScanLabel;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGuesterRecognizer];
    
 /*   MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.labelText = @"Some message...";
    hud.margin = 10.0;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    hud.yOffset = height / 2 - 40;
  */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - PRIVATE

- (void)addGuesterRecognizer
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
    // When the app is launched the scan should initially be disabled
    self.isScanEnabled = NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapRecognizer
{
    [self switchScanState];
}

- (void)switchScanState
{
    if (self.isScanEnabled) {
        [self removeScanAnimation];
        [self.tapToScanLabel setHidden:NO];
    }
    else {
        [self addScanAnimation];
        [self.tapToScanLabel setHidden:YES];
    }
    
    self.isScanEnabled = !self.isScanEnabled;
}

- (void)addScanAnimation
{
    [self removeScanAnimation];
    
    [self addScanLine];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDelegate:self];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(screenRect.origin.x , screenRect.size.height - 100)];
    animation.fromValue = [NSValue valueWithCGPoint:self.scanLine.position];
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    animation.duration = 1.8;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    [self.scanLine  addAnimation:animation forKey:@"moveY"];
}

- (void)removeScanAnimation
{
    if (self.scanLine) {
        [self.scanLine removeAllAnimations];
        [self.scanLine removeFromSuperlayer];
    }
}

- (void)addScanLine
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.scanLine = [CAShapeLayer layer];
    
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(screenRect.origin.x+20, screenRect.origin.y+80)];
    [linePath addLineToPoint:CGPointMake(screenRect.size.width-20, screenRect.origin.y+80)];
    self.scanLine.path=linePath.CGPath;
    self.scanLine.fillColor = [[UIColor grayColor] CGColor];
    self.scanLine.opacity = 1.0;
    self.scanLine.strokeColor = [UIColor grayColor].CGColor;
    self.scanLine.lineWidth = 3.0f;
    [self.view.layer addSublayer:self.scanLine];
}


@end
