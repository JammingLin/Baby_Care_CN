//
//  BLEWeatherController.h
//  Amoy Baby Care
//
//  Created by @Arvi@ on 14-1-13.
//  Copyright (c) 2014年 爱摩科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol BLEWeatherControllerDelegate<NSObject>
@optional
-(void)updatedataarray;

@end
@interface BLEWeatherController : NSObject<BLEControllerDelegate>
{
    //bluetooth data
    short errorCode;
    short dataLength;
    long humidityHigh;
    long humidityLow;
    long humidity;
    long temperatureHigh;
    long temperatureLow;
    long temperature;
    
    //light
    long lowlightChannel0;
    long highlightChannel0;
    long lowlightChannel1;
    long highlightChannel1;
    long CH0;
    long CH1;
    double curlux;
    
    //uv
    long lowuv;
    long highuv;
    long adcoutput;
    short uvvalue;
    
    //microphone
    long lowphone;
    long highphone;
    long phonevalue;
    double phonethrans;
    long lowmaxphone;
    long highmaxphone;
    double maxphonethrans;
    
    BOOL isFistTip;
    BOOL isTimeOut;
    BOOL isFound;
    BOOL isFistTime;
    BOOL isBLEConnected;
    int  getindex;
    NSTimer *checktimer;
    NSTimer *gettimer;
    NSTimeInterval getDataTimeInterval;
}
@property (strong, nonatomic) BLEController *blecontroller;
@property (assign) id<BLEWeatherControllerDelegate> bleweatherControllerDelegate;
+(id)bleweathercontroller;
-(BOOL)isConnected;
-(void)checkbluetooth;

@end
