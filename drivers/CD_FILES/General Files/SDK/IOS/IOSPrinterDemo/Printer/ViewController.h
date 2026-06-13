//
//  ViewController.h
//  Printer
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral, CBCharacteristic;

@interface ViewController : UIViewController


#pragma mark - PosSDKDelegate// 发现周边
- (void)PosdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
// 连接周边
- (void)PosdidConnectPeripheral:(CBPeripheral *)peripheral;
// 连接失败
- (void)PosdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
// 断开连接
- (void)PosdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
// 发送数据成功
- (void)PosdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;

@end

