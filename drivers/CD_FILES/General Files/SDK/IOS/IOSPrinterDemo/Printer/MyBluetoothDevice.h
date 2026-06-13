//
//  MyBluetoothDevice.h
//  print
//
//  Created by ding on 2019/7/18.
//  Copyright © 2019 ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTDeviceCell.h"
@class CBPeripheral, CBCharacteristic;

@interface MyBluetoothDevice : UIViewController


#pragma mark - ZywellSDKDelegate// 发现周边
- (void)ZywelldidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
// 连接周边
- (void)ZywelldidConnectPeripheral:(CBPeripheral *)peripheral;
// 连接失败
- (void)ZywelldidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
// 断开连接
- (void)ZywelldidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
// 发送数据成功
- (void)ZywelldidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;


@end

