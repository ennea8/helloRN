//
//  BP3LManager.m
//  helloRN
//
//  Created by 樊金辉 on 6/19/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

#import "BP3LManager.h"
#import "ScanDeviceController.h"
#import "ConnectDeviceController.h"



@implementation BP3LManager{


  BP3LController *bp3lController;
  
  NSMutableDictionary *callbackList;
  
  NSMutableDictionary *deviceIDPSList;
  
  NSNumber*commandState;
  
  
  
  NSMutableArray *discoverBP3LDevices;

  

}

@synthesize bridge = _bridge;
//@synthesize isPlugged;

RCT_EXPORT_MODULE();

- (instancetype)init
{
  
  NSLog(@"BP3L React Native Module - init");

  if ((self = [super init])) {
    
    discoverBP3LDevices=[[NSMutableArray alloc]init];
    
    
    callbackList = [[NSMutableDictionary alloc]init];
    
    deviceIDPSList = [[NSMutableDictionary alloc]init];
    
    
    bp3lController = [BP3LController shareBP3LController];
    
    commandState=[NSNumber numberWithInt:0];
    
    
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP3LDiscover:) name:BP3LDiscover object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP3L:) name:BP3LConnectNoti object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP3L:) name:BP3LDisConnectNoti object:nil];
//    
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP3LConnectFailed:) name:BP3LConnectFailed object:nil];
    
    
    [BP3LController shareBP3LController];
    
    commandState=[NSNumber numberWithInt:0];

  }
  return self;
}



RCT_EXPORT_METHOD(startDiscover:(NSString *)appsecret callback:(RCTResponseSenderBlock)callback)
{
  //callback(@[[self discoverBP3L]]);
  //callback(@[@"hello bp3l"]);
  
  NSLog(@"开始扫描");
  
  
  [self registerDiscoveryNoti];
  
  bp3lController = [BP3LController shareBP3LController];


  
  
  //[[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BP3L appSecret:appsecret];
  [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BP3L];

  
}

RCT_EXPORT_METHOD(connectDevice:(NSString *)appsecret mac:(NSString *)mac callback:(RCTResponseSenderBlock)callback)
{

  NSLog(@"开始连接");
  
  
  //Whether device exist or not
  BP3L *bp3lInstance = [self getBP3LwithMac:mac];
  
  if ( bp3lInstance==nil) {
    [self registerConnectNoti];
    [self registerConnectFailedNoti];
    
    NSDictionary *tempIDPSDic = [deviceIDPSList valueForKey:mac];
    HealthDeviceType deviceType = HealthDeviceType_BP3L;
    NSString *deviceName = nil;
    
//    if (tempIDPSDic) {
//      deviceName = [tempIDPSDic valueForKey:@"DeviceName"];
//      if ([deviceName isEqual:@"BP5"]){
//        deviceType = HealthDeviceType_BP5;
//      }
//    }
    
    //int paraResult = [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:deviceType andSerialNub:mac appSecret:appsecret];
     //todo 未传 appsecret？
     int paraResult = [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:deviceType andSerialNub:mac];
    
    
    if (paraResult == 1) {
      //[self sendErrorWithMac:mac deviceType:deviceName errorID:@700 commandID:command.callbackId];
      NSLog(@"connectDevice errorID:@700 ");

    }
    else if(paraResult == 2) {
      //[self sendErrorWithMac:mac deviceType:deviceName errorID:@600 commandID:command.callbackId];
      NSLog(@"connectDevice errorID:@600 ");

    }
    
    
    
  }
  else {
    NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
    
    [message setValue:@"Connected" forKey:@"msg"];
    [message setValue:mac forKey:@"address"];
    
    [message setValue:@"BP3L" forKey:@"name"];
    
//    if ([[self isBP5OrBP3LwithMac:mac] isEqualToString:@"BP3L"]) {
//      [message setValue:@"BP3L" forKey:@"name"];
//      
//    }else{
//      [message setValue:@"BP5" forKey:@"name"];
//    }
    //[self sendCallBackSomeJsonData:message commandID:command.callbackId];
    
    
    //已连接？
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Connect" body:message];

    
  }
  
  
}

RCT_EXPORT_METHOD(startMeasure:(NSString *)appsecret mac:(NSString *)mac callback:(RCTResponseSenderBlock)callback)
{
  
  
  NSLog(@"开始测量");
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  
  
  BP3L *bp3lInstance = [self getBP3LwithMac:mac];
  
  
  if(bp3lInstance!=nil){
    
    commandState=@1;
    
    [message setValue:bp3lInstance.serialNumber forKey:@"address"];
    
    [message setValue:@"BP3L" forKey:@"name"];
    
    [bp3lInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
      NSLog(@"Authentication Result:%d",result);
      //tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
      
      
    } pressure:^(NSArray *pressureArr) {
      //tipTextView.text = [NSString stringWithFormat:@"pressureArr%@",pressureArr];
      
      NSLog(@"pressureArr:%@",[NSString stringWithFormat:@"pressureArr%@",pressureArr]);
      
      
      [message setValue:@"MeasureDoing" forKey:@"msg"];
      [message setValue:pressureArr forKey:@"pressure"];

      
      [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Measure" body:message];

      
      
    } xiaoboWithHeart:^(NSArray *xiaoboArr) {
      
    } xiaoboNoHeart:^(NSArray *xiaoboArr) {
      
    } result:^(NSDictionary *dic) {
      NSLog(@"dic:%@",dic);
      //tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
      
      NSLog(@"%@",[ NSString stringWithFormat:@"result:%@",dic ]);
      
      
      [message removeAllObjects];
      [message setValue:@"MeasureDone" forKey:@"msg"];
      [message setValue:bp3lInstance.serialNumber forKey:@"address"];
      [message setValue:[dic valueForKey:@"highpressure"] forKey:@"highpressure"];
      [message setValue:[dic valueForKey:@"lowpressure"]  forKey:@"lowpressure"];
      [message setValue:[dic valueForKey:@"heartRate"]  forKey:@"heartrate"];
      [message setValue:[dic valueForKey:@"arrhythmia"]  forKey:@"arrhythmia"];
      
      [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Measure" body:message];

      
    } errorBlock:^(BPDeviceError error) {
      NSLog(@"error:%d",error);
      //tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
      
      
      [message removeAllObjects];
      [message setValue:@"Error" forKey:@"msg"];
      //[message setValue:error forKey:@"detail"];

      
      
      if (error==BPDidDisconnect) {
        
        //[self sendDisConnectWithMac:mac deviceType:@"BP3L" commandID:command.callbackId];
        
      }else{
        
        //[self sendErrorWithMac:mac deviceType:@"BP3L" errorID:[NSNumber numberWithInt:error] commandID:command.callbackId];
      }

      
      [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Measure" body:message];

      
    }];
    
    
    
  }else{
    
    
//    if ([[self isBP5OrBP3LwithMac:mac] isEqualToString:@"BP3L"]) {
//      
//      [self sendErrorWithMac:mac deviceType:@"BP3L" errorID:@400 commandID:command.callbackId];
//      
//    }else{
//      
//      [self sendErrorWithMac:mac deviceType:@"BP5" errorID:@400 commandID:command.callbackId];
//    }
  }
  
  

}





//////////private//////////////

-(void)sendErrorWithMac:(NSString*)mac deviceType:(NSString*)devicetype errorID:(NSNumber*)errorID commandID:(NSString*)commandID{
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  [message setValue:@"Error" forKey:@"msg"];
  
  [message setValue:errorID forKey:@"errorid"];
  
  [message setValue:@"BP" forKey:@"producttype"];
  
  [message setValue:mac forKey:@"address"];
  
  [message setValue:devicetype forKey:@"productmodel"];
  
  
  //[self sendCallBackSomeJsonData:message commandID:commandID];
  
}

-(void)discoverBP3L:(NSNotification *)tempNoti{
  NSLog(@"in discoverBP3L");
  
  //NSLog(@"Disover:%@",[tempNoti userInfo]);

  
  NSDictionary *infoDic = [tempNoti userInfo];
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  NSString *serialNumber = [infoDic objectForKey:@"SerialNumber"];
  
  NSNumber *rssi = [infoDic objectForKey:@"RSSI"];
  
  [message setValue:@"Discovery" forKey:@"msg"];
  
  [message setValue:serialNumber forKey:@"address"];
  
  [message setValue:@"BP3L" forKey:@"name"];
  
  [message setValue:rssi forKey:@"rssi"];
  
  [deviceIDPSList setValue:infoDic forKey:serialNumber];
  
  //[self sendCallBackSomeJsonData:message commandID:[callbackList valueForKey:@"DiscoverBP3LCallbackId"]];
  
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Discovery" body:message];

  
}

-(void)deviceConnectedBP3L:(NSNotification *)tempNoti{
  
  NSDictionary *infoDic = [tempNoti userInfo];
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  NSString *serialNumber = [infoDic objectForKey:@"SerialNumber"];
  
  [message setValue:@"Connected" forKey:@"msg"];
  
  [message setValue:serialNumber forKey:@"address"];
  
  [message setValue:@"BP3L" forKey:@"name"];
  
  [deviceIDPSList setValue:infoDic forKey:serialNumber];
  

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"BP3L_Connect" body:message];

  
}

-(void)deviceConnectFailedBP3L:(NSNotification *)tempNoti{
  
  [self unregisterConnectNoti];
  [self unregisterConnectFailedConnectNoti];
  
  NSDictionary *infoDic = [tempNoti userInfo];
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  NSString *serialNumber = [infoDic objectForKey:@"SerialNumber"];
  
  [message setValue:@"Error" forKey:@"msg"];
  
  [message setValue:@300 forKey:@"errorid"];
  
  [message setValue:serialNumber forKey:@"address"];
  
  [message setValue:@"BP3L" forKey:@"name"];
  
  if (serialNumber) {
    [deviceIDPSList removeObjectForKey:serialNumber];
  }
  
  //[self sendCallBackSomeJsonData:message commandID:[callbackList valueForKey:@"DeviceConnectFailedBP3LCallbackId"]];
  
}

- (BP3L*) getBP3LwithMac:(NSString *)mac{
  
  bp3lController = [BP3LController shareBP3LController];
  
  NSArray *bpDeviceArray = [bp3lController getAllCurrentBP3LInstace];
  
  if (bpDeviceArray.count>0 && mac.length>0)
  {
    for(BP3L *tempBP3L in bpDeviceArray){
      
      if([mac isEqualToString:tempBP3L.serialNumber]){
        
        return tempBP3L;
        break;
        
      }
    }
  }
  
  return nil;
  
}




-(void)discoveryDone:(NSNotification *)tempNoti{
  
  NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
  
  [message setValue:@"DiscoveryDone" forKey:@"msg"];
  
}


#pragma mark - Register Unregister Noti

//Register discorety noti
- (void) registerDiscoveryNoti{

  
  //BP3L
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BP3LDiscover" object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(discoverBP3L:) name:@"BP3LDiscover" object:nil];
  
  //todo DiscoveryDone not defined?
  // [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DiscoveryDone" object:nil];
  // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(discoveryDone:) name:@"DiscoveryDone" object:nil];
  

  
}

//Unregister discorety noti
-(void) unregisterDiscoveryNoti{
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BP3LDiscover" object:nil];
  
}

//Register connect noti
- (void) registerConnectNoti{
 
  //BP3L
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BP3LConnectNoti" object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnectedBP3L:) name:@"BP3LConnectNoti" object:nil];
}

//Unregister connect noti
-(void) unregisterConnectNoti{
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BP3LConnectNoti" object:nil];
}

//Register connect failed noti
- (void) registerConnectFailedNoti{
  
  //BP3L
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DeviceConnectBP3LFailed" object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnectFailedBP3L:) name:@"DeviceConnectBP3LFailed" object:nil];
  
}
//Unregister connect failed noti
-(void) unregisterConnectFailedConnectNoti{
  [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DeviceConnectBP3LFailed" object:nil];
}



@end