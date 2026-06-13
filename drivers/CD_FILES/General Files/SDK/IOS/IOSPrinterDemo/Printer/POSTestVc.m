//
//  XinYeTestVc.m
//  Printer
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "POSTestVc.h"
#import "POSInputVc.h"
#import "POSBLEManager.h"
@interface POSTestVc ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation POSTestVc
- (IBAction)backClick:(id)sender {
//    [[PosSDK sharedCBTools] disconnectRootPeripheral];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;

    [self initNav];
}

- (void)initNav {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn addTarget:self action:@selector(sendPrintMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = item;
}

- (void)sendPrintMessage {
    [[POSBLEManager sharedInstance] POSsendDataToPeripheral:[POSBLEManager sharedInstance].writePeripheral dataString:@"is test Message..."];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Id = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Id];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%zd、%@",indexPath.row+1,self.dataArr[indexPath.row]];
    NSInteger row = indexPath.row+1;
    
    // 方法不需要传参数
    if (row == 1 || row == 2 || row == 3 || row == 4 || row == 8 || row == 16 || row == 20 || row == 25 || row == 28 || row == 48 || row == 65 || row == 67 || row == 74 || row == 75 || row == 76 || row == 77 || row == 78  ) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSInteger row = indexPath.row+1;
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSString *titleStr = cell.textLabel.text;
//    
//    XinYeInputVc *inputVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"XinYeInputVc"];
//    inputVc.title = titleStr;
//    inputVc.row = row;
//    
//    if (row == 1) {
//        [[PosBLEManager sharedInstance] PoshorizontalPosition];
//    }else if (row == 2) {
//        [[PosBLEManager sharedInstance] PosprintAndFeed];
//    }else if (row == 3) {
//        [[PosBLEManager sharedInstance] PosPrintAndBackToNormalModel];
//    }else if (row == 4) {
//        [[PosBLEManager sharedInstance] PosCancelPrintData];
//    }else if (row == 8) {
//        [[PosBLEManager sharedInstance] PosPrintOnPageModel];
//    }else if (row == 16) {
//        [[PosBLEManager sharedInstance] PosSetDefaultLineMargin];
//    }else if (row == 20) {
//        [[PosBLEManager sharedInstance] PosInitializePrinter];
//    }else if (row == 25) {
//        [[PosBLEManager sharedInstance] PosSelectPageModel];
//    }else if (row == 28) {
//        [[PosBLEManager sharedInstance] PosSelectNormalModel];
//    }else if (row == 48) {
//        [[PosBLEManager sharedInstance] PosBeginOrEndDefine];
//    }else if (row == 65) {
//        [[PosBLEManager sharedInstance] PosSelectChineseCharacterModel];
//    }else if (row == 67) {
//        [[PosBLEManager sharedInstance] PosCancelChineseModel];
//    }else if (row == 74) {
//        [[PosBLEManager sharedInstance] PosSetCommandMode:1];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经设置为批量打印模式！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else if (row == 75) {
//        [[PosBLEManager sharedInstance] PosSetCommandMode:0];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经关闭批量打印模式！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else if (row == 76) { //显示发送缓冲区内容
//        NSArray *array;
//        array=[[PosBLEManager sharedInstance] PosGetBuffer];
//        [self displayBufferContent:array];
//    }
//    else if (row == 77) {//清除发送缓冲区内容
//        [[PosBLEManager sharedInstance] PosClearBuffer];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送缓冲区内容已清除！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else if (row == 78) {//批量发送指令
//        [[PosBLEManager sharedInstance] PosSendCommandBuffer];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"批量指令已经发送！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else {
//        [self.navigationController pushViewController:inputVc animated:YES];
//    }
    
}

-(void)displayBufferContent:(NSArray*)commandbuffer
{
    NSString *bufferContent;
    bufferContent=@"";
    for (int t=0;t<[commandbuffer count];t++)
    {
        NSString *tmp;
        tmp=[NSString stringWithFormat:@"第%i条 : ",t];
        NSData *data;
        data=[commandbuffer objectAtIndex:t];
        tmp=[NSString stringWithFormat:@"%@%@\n",tmp,[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]];
        bufferContent=[bufferContent stringByAppendingString:tmp];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"缓冲区内容" message:bufferContent delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
    [alertView show];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithObjects:@"水平定位",@"打印并换行",@"打印并回到标准模式",@"页模式下取消打印数据",@"实时状态传送",@"实时对打印机请求",@"实时产生钱箱开启脉冲",@"页模式下打印",@"设置字符右间距",@"选择打印模式",@"设置绝对打印位置",@"选择/取消用户自定义字符",@"定义用户自定义字符",@"选择位图模式",@"选择/取消下划线模式",@"设置默认行间距",@"设置行间距",@"选择打印机",@"取消用户自定义字符",@"初始化打印机",@"设置横向跳格位置",@"选择/取消加粗模式",@"选择/取消双重打印模式",@"打印并走纸",@"选择页模式",@"选择字体",@"选择国际字符集",@"选择标准模式",@"在页模式下选择打印区域方向",@"选择/取消顺时针选择90度",@"页模式下设置打印区域",@"设置相对横向打印位置",@"选择对齐方式",@"选择打印纸传感器以输出缺纸信号",@"选择打印纸传感器以停止打印",@"允许/禁止按键",@"打印并向前走纸N行",@"产生钱箱控制脉冲",@"选择字符代码表",@"选择/取消倒置打印模式",@"打印下载到FLASH中的位图",@"定义Flash位图",@"选择字符大小",@"页模式下设置纵向绝对位置",@"定义下载位图",@"执行打印数据十六进制转储",@"打印下载位图",@"开始/结束宏定义", @"选择/取消黑白反显打印模式", @"选择HRI字符的打印位置",@"设置左边距",@"设置横向和纵向移动单位",@"选择切纸模式并切纸",@"设置打印区域宽高", @"页模式下设置纵向相对位置", @"执行宏命令", @"打开/关闭自动状态反传功能(ASB)",@"选择HRI使用字体", @"选择条码高度",@"打印条码",@"返回状态", @"打印光栅位图",@"设置条码宽度",@"设置汉字字符模式",@"选择汉字模式",@"选择/取消汉字下划线模式",@"取消汉字模式", @"定义用户自定义汉字", @"设置汉字字符左右间距", @"选择/取消汉字倍高倍宽",@"空",@"打印机来单打印蜂鸣提示",@"打印机来单打印蜂鸣提示及报警灯闪烁",@"打开批量发送模式",@"关闭批量发送模式",@"显示发送缓冲区内容",@"清除发送缓冲区",@"批量发送指令", nil];
    }
    return _dataArr;
}
@end
