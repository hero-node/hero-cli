//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "HeroScanBarCodeView.h"

@implementation HeroScanBarCodeView
{
    CALayer *baselineLayer;
    CABasicAnimation *animation;
    BOOL isAnimation;
}
-(void)on:(NSDictionary *)json
{
    [super on:json];
    isAnimation = YES;
    [self initScan];
}
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        [self initScan];
    }
    return self;
}
-(void)didMoveToSuperview
{
    [self scanStart];
    [self startBaseLineAnimation];
}
-(void)dealloc
{
    [self scanStop];
    [self stopBaseLineAnimation];
}
-(void)removeFromSuperview
{
    [self scanStop];
    [self stopBaseLineAnimation];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.scanRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.preview.frame = self.bounds;
    baselineLayer = [[CALayer alloc]init];
    [baselineLayer setBounds:CGRectMake(0, 0, frame.size.width, 2)];
    [baselineLayer setBackgroundColor:[[UIColor redColor] CGColor]];
}

-(void)initScan
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSString * mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if ([[AVCaptureDevice devices] count] == 0 || authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
            return;
        }
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        // Output
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode,AVMetadataObjectTypePDF417Code
        _output.metadataObjectTypes =@[AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode];
        
        // Preview
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = self.bounds;
        [self.layer insertSublayer:self.preview atIndex:0];
    }
    
}

-(void)setScanRect:(CGRect)rect
{
    //设置AVCaptureMetadataOutput  的rectOfInterest 的属性就可以设置可扫描区域了   这样设置就可以：CGRectMake（y的起点/屏幕的高，x的起点/屏幕的宽，扫描的区域的高/屏幕的高，扫描的区域的宽/屏幕的宽）
    _output.rectOfInterest = CGRectMake(rect.origin.y/self.frame.size.height, rect.origin.x/self.frame.size.width, rect.size.height/self.frame.size.height, rect.size.width/self.frame.size.width);
}

-(void)scanStart
{
    [_session startRunning];
}

-(void)scanStop
{
    [_session stopRunning];
    isAnimation = NO;
}

-(void)startBaseLineAnimation
{
    if (!baselineLayer.superlayer) {
        [self.layer addSublayer:baselineLayer];
    }
    animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2, 0)]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height)]];
    [animation setDuration:2];
    [baselineLayer addAnimation:animation forKey:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (isAnimation) {
        [self startBaseLineAnimation];
    }else{
        [baselineLayer removeFromSuperlayer];
        animation = nil;
        isAnimation = YES;
    }
}
-(void)stopBaseLineAnimation
{
    isAnimation = NO;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    [self scanStop];
    if (stringValue) {
        if (self.json[@"getBarCode"]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.json[@"getBarCode"]];
            [dic setObject:stringValue forKey:@"value"];
            [self.controller on:dic];
        }
    }
}
@end
