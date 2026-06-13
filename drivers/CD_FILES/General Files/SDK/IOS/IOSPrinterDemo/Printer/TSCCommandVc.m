//
//  TSCCommandVc.m
//  Printer
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "TSCCommandVc.h"
#import "WIFIInputVc.h"

@interface TSCCommandVc ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation TSCCommandVc

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)sendMsg:(id)sender {
    NSString *str=_tf_param.text;
    [self.manager POSWriteCommandWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Id = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger row = indexPath.row+1;
    if (row == 9 || row == 12 || row == 13 || row == 32 || row == 33 || row == 34 || row == 35 || row == 36) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text  = [NSString stringWithFormat:@"%zd.%@",row,self.dataArr[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row + 1;
    if (row == 9) {
        [self.manager POSWriteCommandWithData:[TscCommand cls]];
    }else if (row == 12) {
        [self.manager POSWriteCommandWithData:[TscCommand formFeed]];
    }else if (row== 13) {
        [self.manager POSWriteCommandWithData:[TscCommand home]];
    }else if (row== 32) {
        [self.manager POSSetCommandMode:1]; //打开批量发送模式
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经设置为批量打印模式！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alertView show];
    }else if (row== 33) {
        [self.manager POSSetCommandMode:0]; //关闭批量发送模式
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经关闭为批量打印模式！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alertView show];
    }else if (row== 34) {
        NSArray *commandbuffer;
        commandbuffer=[self.manager POSGetBuffer]; //显示发送缓冲区内容
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
        return;
    }else if (row== 35) {
        [self.manager POSClearBuffer]; //清除发送缓冲区
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送缓冲区内容已清除！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alertView show];
    }else if (row== 36) {
        [self.manager POSSendCommandBuffer]; //批量发送指令
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"批量指令已经发送！" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alertView show];
    }else {
        WIFIInputVc *inputVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"WIFIInputVc"];
        inputVc.row = row;
        inputVc.manager = self.manager;
        [self.navigationController pushViewController:inputVc animated:YES];
    }
    
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithObjects:@"设置标签尺寸",@"设置间隙长度",@"产生钱箱控制脉冲",@"控制每张标签的停止位置",@"设置打印速度",@"设置打印浓度",@"设置打印方向和镜像",@"设置原点坐标",@"清除打印缓冲区数据",@"走纸",@"退纸",@"走一张标签纸距离",@"标签位置进行一次校准",@"打印标签",@"设置国际代码页",@"设置蜂鸣器",@"设置打印机报错",@"在打印缓冲区绘制黑块",@"在打印缓冲区绘制一维条码",@"在打印缓冲区绘制矩形",@"在打印缓冲区绘制位图",@"擦除打印缓冲区中指定区域的数据",@"将指定区域的数据黑白反色",@"将指定区域的数据黑白反色",@"在打印缓冲区中绘制文字",@"设置剥离功能是否开启",@"设置撕离功能是否开启",@"设置切刀功能是否开启",@"设置打印机出错时，是否打印上一张内容",@"设置是否按走纸键打印最近一张标签",@"设置按走纸键打印最近一张标签的份数", @"打开批量发送模式",@"关闭批量发送模式",@"显示发送缓冲区内容",@"清除发送缓冲区",@"批量发送指令",nil];
    }
    return _dataArr;
}
@end
