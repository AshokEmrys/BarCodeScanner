//
//  ScannerViewController.m
//  BarCodeScanner
//
//  Created by ParokshaX on 06/01/16.
//  Copyright © 2016 ParokshaX. All rights reserved.
//

#import "ScannerViewController.h"
#import "MTBBarcodeScanner.h"
#import "MBProgressHUD.h"

@interface ScannerViewController ()

@property(nonatomic) MTBBarcodeScanner *scanner;
@property (weak, nonatomic) IBOutlet UIView *scannerPreview;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property(nonatomic) BOOL isScanning;
@property(nonatomic) CAShapeLayer *scanLine;
@property (weak, nonatomic) IBOutlet UILabel *tapToScanLabel;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGuesterRecognizer];
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerPreview];
    
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


- (void)viewWillDisappear:(BOOL)animated
{
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

#pragma mark - UI Events

- (IBAction)flashButtonTapped:(id)sender {
    
    if (self.scanner.torchMode == MTBTorchModeOff) {
        
        self.scanner.torchMode = MTBTorchModeAuto;
    }
    else if (self.scanner.torchMode == MTBTorchModeAuto) {
        self.scanner.torchMode = MTBTorchModeOn;
    }
    else {
        self.scanner.torchMode = MTBTorchModeOn;
    }
    
}

#pragma mark - PRIVATE

- (void)addGuesterRecognizer
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
    // When the app is launched the scan should initially be disabled
    self.isScanning = NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapRecognizer
{
    [self toggleScanState];
}

- (void)toggleScanState
{
    if (self.isScanning) {
        [self stopScanning];
    }
    else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self startScanning];
            }
            else {
                [self displayCameraErrorAlert];
            }
        }];
        
    }
}

- (void)manipulateFlashButtonIconForMode:(MTBTorchMode) mode
{
    
}

- (void)startScanning
{
    [self addScanAnimation];
    [self.tapToScanLabel setHidden:YES];
    
    //Start Scanning
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {

    }];
    
    [self.flashButton setEnabled:YES];
    [self.switchCameraButton setEnabled:YES];
}

- (void)stopScanning
{
    [self removeScanAnimation];
    [self.tapToScanLabel setHidden:NO];
    [self.flashButton setEnabled:NO];
    [self.switchCameraButton setEnabled:NO];
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

- (void)processScannedCodes:(NSArray *)codes
{
    
}

- (void)displayCameraErrorAlert
{
    NSString *message = nil;
    
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have sufficient permission to access the camera.";
    }
    else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    }
    else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}


@end
