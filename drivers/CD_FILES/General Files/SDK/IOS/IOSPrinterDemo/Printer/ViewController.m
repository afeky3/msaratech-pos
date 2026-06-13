//
//  ViewController.m
//  Printer
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "ViewController.h"
#import "POSBLEManager.h"
#import "ConnectVc.h"
#import "POSTestVc.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,POSBLEManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSArray *rssiList;
@property (nonatomic,strong) POSBLEManager *manager;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated  {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.manager = [POSBLEManager sharedInstance];
//    self.manager.delegate = self;
    [self.manager POSstartScan];

}


#pragma mark - PosSDKDelegate
- (void)POSdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList{
    _dataArr = [NSMutableArray arrayWithArray:peripherals];
    _rssiList = rssiList;
    [_myTable reloadData];
}

/** 连接成功 */
- (void)POSdidConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%s",__func__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        POSTestVc *xinYe = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"XinYeTestVc"];
        xinYe.title = peripheral.name;
        xinYe.testArr = self.dataArr;
        
        // 切换到下一个控制器
//        [self.navigationController pushViewController:xinYe animated:YES];
        
        // 返回主页控制器
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

// 连接失败
- (void)POSdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [MBProgressHUD showError:@"连接失败" toView:self.view];
}

// 写入数据成功
- (void)POSdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error {
    
}
// 断开连接
- (void)POSdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    
    if (isAutoDisconnect) {
        NSLog(@"自动断开...");
        [self.navigationController popToViewController:self animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"device disconnect" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [self scanAgain:nil];
    }else {
        NSLog(@"手动断开...");
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    });
    
    NSLog(@"%s",__func__);
}

#pragma mark - 表数据源 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"printerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CBPeripheral *peripheral = self.dataArr[indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    if (peripheral.name.length == 0) {
        cell.textLabel.text = @"未知";
    }
    NSNumber *rssi =_rssiList[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%zd",rssi.integerValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = self.dataArr[indexPath.row];
    NSString *message =  [NSString stringWithFormat:@"正在连接%@",peripheral.name];
    [MBProgressHUD showMessag:message toView:self.view];

    // 连接周边
    [self.manager POSconnectDevice:peripheral];
    self.manager.writePeripheral = peripheral;
}
- (IBAction)scanAgain:(id)sender {
    [self.dataArr removeAllObjects];
    [self.myTable reloadData];
    [self.manager POSdisconnectRootPeripheral];
    [self.manager POSstartScan];
}
// 切换WIFI模式
- (IBAction)changeWIFIModel:(id)sender {
    [_manager POSstopScan];
    ConnectVc *connect = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ConnectVc"];
    connect.title = @"Printer_WIFI";
    [self.navigationController pushViewController:connect animated:YES];
}

#pragma mark - lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
@end
