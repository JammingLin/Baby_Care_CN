//
//  LookingForDeviceViewController.m
//  Amoy Baby Care
//
//  Created by CHEN WEIBIN on 13-12-17.
//  Copyright (c) 2013年 爱摩科技有限公司. All rights reserved.
//

#import "LookingForDeviceViewController.h"
#import "MyDevicesViewController.h"
@interface LookingForDeviceViewController ()
{
    UartLib *uartLib;
    CBPeripheral	*connectPeripheral;
}
@end

@implementation LookingForDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFound =YES;
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    _bleController = [[BLEController alloc]init];
    _bleController.bleControllerDelegate = self;
    
    [self startScanDevice];
}

-(void)BLEPowerOff:(BOOL)isPowerOff
{
    if (isPowerOff) {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"" message:@"记录设备没有足够电量,请充电" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alter show];
    }
}

-(void)DidConnected:(BOOL)isConnected
{
    NSLog(@"Look for device viewController!did connected");
}

-(void)DisConnected:(BOOL)isConnected
{
    NSLog(@"Look for device viewController!DisConnected");
}

-(void)scanResult:(BOOL)result with:(NSMutableArray  *)foundPeripherals{
    if (!result) {
        isTimeOut=YES;
    }
    else{
        if (isFound) {
            peripherals=foundPeripherals;
            [_bleController stopscan];
            if (_deviceId==1 && [[[peripherals objectAtIndex:0] name] isEqualToString:@"BLE_COM"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"搜索到活动记录设备" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
                [alert show];
            }
            else if (_deviceId==2 && [[[peripherals objectAtIndex:0] name] isEqualToString:@"BLE_ENV"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"搜索到环境记录设备" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
                [alert show];
            }

            
        }
        isFound=NO;
    }
}

-(void)startScanDevice
{
    //根据设备id加载背景图
    _imageView.image = [UIImage imageNamed:@"lookingDevice.jpg"];
    if (_deviceId==1) {
        //_imageView.image = [UIImage imageNamed:@"lookingDevice.jpg"];
    }
    else if (_deviceId==2){
        //
    }
    [self.view addSubview:_imageView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeGo) userInfo:nil repeats:YES];
    isTimeOut=NO;
    [_bleController startscan];
}

-(void)reScanDevice
{
    [_buttonRescan removeFromSuperview];
    [self startScanDevice];
}

-(void)timeGo
{
    if (isTimeOut) {
        [self scanFail];
        [timer invalidate];
    }
}

-(void)scanFail
{
    [_bleController stopscan];
    NSLog(@"搜索失败,停止搜索配件");
    _imageView.image = [UIImage imageNamed:@"scanfail_1.jpg"];
    _buttonRescan = [[UIButton alloc]initWithFrame:CGRectMake(100, 360, 120, 24)];
    [_buttonRescan setTitle:@"重新搜寻" forState:UIControlStateNormal];
    [self.view addSubview:_buttonRescan];
}

#pragma UIAlert protocol
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (peripherals == nil) {
        return;
    }
    if (buttonIndex==0) {
        //活动信息设备绑定
        if (_deviceId==1 && [[[peripherals objectAtIndex:0] name] isEqualToString:@"BLE_COM"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[[peripherals objectAtIndex:0] name] forKey:@"BLE_COM"];
            
            for (UIViewController *myDT in self.navigationController.viewControllers) {
                
                if ([myDT isKindOfClass:[MyDevicesViewController class]]) {
                    [self.navigationController popToViewController:myDT animated:YES];
                    break;
                }
            }
        }
        else if (_deviceId==2 && [[[peripherals objectAtIndex:0] name] isEqualToString:@"BLE_ENV"]){
            [[NSUserDefaults standardUserDefaults] setObject:[[peripherals objectAtIndex:0] name] forKey:@"BLE_ENV"];
            
            for (UIViewController *myDT in self.navigationController.viewControllers) {
                if ([myDT isKindOfClass:[MyDevicesViewController class]]) {
                    [self.navigationController popToViewController:myDT animated:YES];
                    break;
                }
            }
            
            [[BLEWeatherController bleweathercontroller] checkbluetooth];
        }
    }
    else if (buttonIndex==1){
        return;
    }
}


#pragma sys

-(void)viewDidAppear:(BOOL)animated{
   
}

-(void)viewWillDisappear:(BOOL)animated {
    [_bleController stopscan];
    NSLog(@"跳出页面,停止搜索配件");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
