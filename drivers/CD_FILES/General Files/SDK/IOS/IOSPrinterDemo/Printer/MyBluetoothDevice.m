//
//  ViewController.m
//  print
//
//  Created by ding on 2019/7/18.
//  Copyright © 2019 ding. All rights reserved.
//

#import "MyBluetoothDevice.h"
#import "POSBLEManager.h"

@interface MyBluetoothDevice ()<UITableViewDelegate,UITableViewDataSource,POSBLEManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *rssiList;
@property (nonatomic,strong) POSBLEManager *manager;

@end

@implementation MyBluetoothDevice

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [POSBLEManager sharedInstance];
    self.manager.delegate = self;
//    [self.manager POSdisconnectRootPeripheral];
    [self.manager POSstartScan];
    self.myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIRefreshControl * rc = [[UIRefreshControl alloc]init];//初始化UIRefreshControl
    rc.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull down to refresh"];//设置下拉框控件标签
    [rc addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];//添加下拉刷新事件
    self.myTable.refreshControl = rc;
}
//下拉刷新事件
-(void)refreshAction
{
    if(self.myTable.refreshControl.refreshing)
    {
        self.myTable.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Loading..."];//设置下拉框控件标签
        [self.manager POSstartScan];
        [self.myTable.refreshControl endRefreshing];//结束刷新
        self.myTable.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull down to refresh"];
        [self.myTable reloadData];
    }
}
#pragma mark - ZywellSDKDelegate
- (void)POSdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList{
    _dataArr = [NSMutableArray arrayWithArray:peripherals];
//    NSLog(@"MyBluetoothDevice%@",self.dataArr);
    _rssiList = [NSMutableArray arrayWithArray:rssiList];
    [_myTable reloadData];
}

/** 连接成功 */
- (void)POSdidConnectPeripheral:(CBPeripheral *)peripheral{
//    NSLog(@"%s",__func__);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Connect success" message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
}

// 连接失败
- (void)POSdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    [MBProgressHUD hideHUDForView:self.view animated:NO];
//    [MBProgressHUD showError:@"连接失败" toView:self.view];
}

// 写入数据成功
- (void)POSdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error {
    NSLog(@"bluetoothdevice");
}
- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}
// 断开连接
- (void)POSdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    if (isAutoDisconnect) {
        NSLog(@"自动断开...");
    } else {
        NSLog(@"手动断开...");
    }
    [self.manager POSstartScan];
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"device disconnect" message:@""
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [self presentViewController:alert animated:YES completion:nil];
//    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [MBProgressHUD hideHUDForView:self.view animated:NO];
//    });
    
//    NSLog(@"%s",__func__);
}

#pragma mark - 表数据源 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"printerCell";
    BTDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[BTDeviceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CBPeripheral *peripheral = self.dataArr[indexPath.row];
    cell.NAME.text =peripheral.name;
    cell.UUID.text = [NSString stringWithFormat:@"UUID:%@", peripheral.identifier.UUIDString];
    if (peripheral.name.length == 0) {
        cell.NAME.text = @"Unknown";
    }
    NSNumber *rssi =_rssiList[indexPath.row];
    cell.RSSI.text = [NSString stringWithFormat:@"RSSI:%zd",rssi.integerValue];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 100;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = self.dataArr[indexPath.row];
    NSString *message =  [NSString stringWithFormat:@"正在连接%@",peripheral.name];
//    [MBProgressHUD showMessag:message toView:self.view];
    
    // 连接周边
    [self.manager POSconnectDevice:peripheral];
    self.manager.writePeripheral = peripheral;
}
- (IBAction)scanAgain{
    [self.dataArr removeAllObjects];
    [self.myTable reloadData];
    [self.manager POSdisconnectRootPeripheral];
    [self.manager POSstartScan];
}
// 切换WIFI模式
- (IBAction)changeWIFIModel:(id)sender {
    [_manager POSstopScan];
//    ConnectVc *connect = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ConnectVc"];
//    connect.title = @"Printer_WIFI";
//    [self.navigationController pushViewController:connect animated:YES];
}

#pragma mark - lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
@end
