//
//  ConnectVc.m
//  Printer
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "ConnectVc.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WIFIInputVc.h"
#import "TSCCommandVc.h"

@interface ConnectVc ()<AsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,POSWIFIManagerDelegate>

//@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *managerArr;
@end

@implementation ConnectVc
/**
    手动断开连接
 */
- (IBAction)disConnect:(id)sender {
    [[POSWIFIManager shareWifiManager] POSDisConnect];
}

/**
    连接主机
 */
- (IBAction)connectBtnClick:(id)sender {
    if (self.tf_host.text.length == 0 || self.tf_send.text.length == 0) {
        return;
    }
    int port = self.tf_send.text.intValue;
    UInt16 port_16 = (UInt16)port;
    POSWIFIManager *mana = [[POSWIFIManager alloc] init];
    mana.delegate = self;
    [mana POSConnectWithHost:_tf_host.text port:port_16 completion:^(BOOL isConnect) {
        if (isConnect) {
            [self.managerArr addObject:mana];
            [self.myTab reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 检查WIFI
    [self fetchSSIDInfo];
    [self initNav];
    
    // 注册代理
//    [WIFIManager shareWifiManager].delegate = self;
    _managerArr = [NSMutableArray array];
}

- (void)initNav {
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setTitle:@"返回" forState:UIControlStateNormal];
    [left setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    left.frame = CGRectMake(0, 0, 44, 44);
    [left addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)backBtnClick {
    for (POSWIFIManager *manager in self.managerArr) {
        [manager POSDisConnect];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WIFIManagerDelegate
/**
    连接上主机
 */
- (void)POSWIFIManager:(POSWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port {
    if (!manager.isAutoDisconnect) {
        self.myTab.hidden = NO;
    }
}
/**
    读取到服务器的数据
 */
- (void)POSWIFIManager:(POSWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag {
    
}
/**
    写数据成功
 */
- (void)POSWIFIManager:(POSWIFIManager *)manager didWriteDataWithTag:(long)tag {
    
}

/**
    断开连接
 */
- (void)POSWIFIManager:(POSWIFIManager *)manager willDisconnectWithError:(NSError *)error {}

- (void)POSWIFIManagerDidDisconnected:(POSWIFIManager *)manager {
    
    if (!manager.isAutoDisconnect) {
        self.myTab.hidden = YES;
    }
    
}

#pragma mark -UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.managerArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Id = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger row = indexPath.row+1;
    cell.textLabel.text  = [NSString stringWithFormat:@"连接%zd",row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TSCCommandVc *tscVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TSCCommandVc"];
    POSWIFIManager *manage = self.managerArr[indexPath.row];
    tscVc.manager = manage;
    [self.navigationController pushViewController:tscVc animated:YES];
}


/**
 检测WIFI
 */
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)showAlert:(NSString *)str {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alter show];
}

//- (NSMutableArray *)dataArr {
//    if (!_dataArr) {
//        _dataArr = [NSMutableArray arrayWithObjects:@"设置标签尺寸",@"设置间隙长度",@"产生钱箱控制脉冲",@"控制每张标签的停止位置",@"设置打印速度",@"设置打印浓度",@"设置打印方向和镜像",@"设置原点坐标",@"清除打印缓冲区数据",@"走纸",@"退纸",@"走一张标签纸距离",@"标签位置进行一次校准",@"打印标签",@"设置国际代码页",@"设置蜂鸣器",@"设置打印机报错",@"在打印缓冲区绘制黑块",@"在打印缓冲区绘制一维条码",@"在打印缓冲区绘制矩形",@"在打印缓冲区绘制位图",@"擦除打印缓冲区中指定区域的数据",@"将指定区域的数据黑白反色",@"将指定区域的数据黑白反色",@"在打印缓冲区中绘制文字",@"设置剥离功能是否开启",@"设置撕离功能是否开启",@"设置切刀功能是否开启",@"设置打印机出错时，是否打印上一张内容",@"设置是否按走纸键打印最近一张标签",@"设置按走纸键打印最近一张标签的份数", nil];
//    }
//    return _dataArr;
//}

@end
