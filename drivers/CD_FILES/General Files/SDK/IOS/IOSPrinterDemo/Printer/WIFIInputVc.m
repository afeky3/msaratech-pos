//
//  WIFIInputVc.m
//  Printer
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "WIFIInputVc.h"

@interface WIFIInputVc ()<UITextViewDelegate>

@end

@implementation WIFIInputVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTextview.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.myTextview.layer.borderWidth = 0.5;
    
}
/**
 发送
 */
- (IBAction)sendMSG:(id)sender {
    
    int p1 = _tf_param1.text.intValue;
    int p2 = _tf_param2.text.intValue;
    int p3 = _tf_param3.text.intValue;
    int p4 = _tf_param4.text.intValue;
    int p5 = _tf_param5.text.intValue;
    int p6 = _tf_param6.text.intValue;
    int p7 = _tf_param7.text.intValue;
    //int p8 = _tf_param8.text.intValue;
    //int p9 = _tf_param9.text.intValue;
    
    
//    NSString *str = _myTextview.text;
    switch (_row) {
        case 1:
            [self.manager POSWriteCommandWithData:[TscCommand sizeBymmWithWidth:p1 andHeight:p2]];
            break;
        case 2:
            [self.manager POSWriteCommandWithData:[TscCommand gapBydotWithWidth:p1 andHeight:p2]];
            break;
        case 3:
            [self.manager POSWriteCommandWithData:[TscCommand initialPrinter]];
            break;
        case 4:
            [self.manager POSWriteCommandWithData:[TscCommand offSetBydotWithM:p1]];
            break;
        case 5:
            [self.manager POSWriteCommandWithData:[TscCommand speed:p1]];
            break;
        case 6:
            [self.manager POSWriteCommandWithData:[TscCommand density:p1]];
            break;
        case 7:
            [self.manager POSWriteCommandWithData:[TscCommand direction:p1]];
            break;
        case 8:
            [self.manager POSWriteCommandWithData:[TscCommand referenceWithX:p1 andY:p2]];
            break;
        case 10:
            [self.manager POSWriteCommandWithData:[TscCommand feed:p1]];
            break;
        case 11:
            [self.manager POSWriteCommandWithData:[TscCommand backFeed:p1]];
            break;
        case 14:
            [self.manager POSWriteCommandWithData:[TscCommand print:p1]];
            break;
        case 15:
            
            [self.manager POSWriteCommandWithData:[TscCommand codePage:@"001"]];
            break;
        case 16:
            [self.manager POSWriteCommandWithData:[TscCommand soundWithLevel:p1 andInterval:p2]];
            break;
        case 17:
            [self.manager POSWriteCommandWithData:[TscCommand limitFeedBydot:p1]];
            break;
        case 18:
            [self.manager POSWriteCommandWithData:[TscCommand barWithX:p1 andY:p2 andWidth:p3 andHeigt:p4]];
            break;
        case 19:
            [self.manager POSWriteCommandWithData:[TscCommand barcodeWithX:p1 andY:p2 andCodeType:@"CODE128" andHeight:p3 andHunabReadable:p4 andRotation:p5 andNarrow:p6 andWide:p7 andContent:@"xxxxxxx" usStrEnCoding:NSASCIIStringEncoding]];
            break;
        case 20:
            [self.manager POSWriteCommandWithData:[TscCommand boxWithX:p1 andY:p2 andEndX:p3 andEndY:p4 andThickness:p5]];
            break;
        case 21:
            [self.manager POSWriteCommandWithData:[TscCommand bitmapWithX:p1 andY:p2 andMode:p3 andImage:[UIImage imageNamed:@"XinYe.bmp"] andBmpType:Dithering]];
            break;
        case 22:
            [self.manager POSWriteCommandWithData:[TscCommand eraseWithX:p1 andY:p2 andWidth:p3 andHeight:p4]];
            break;
        case 23:
            [self.manager POSWriteCommandWithData:[TscCommand reverseWithX:p1 andY:p2 andWidth:p3 andHeight:p4]];
            break;
        case 24:
            
            [self.manager POSWriteCommandWithData:[TscCommand textWithX:p1 andY:p2 andFont:@"001" andRotation:p4 andX_mul:p5 andY_mul:p6 andContent:@"ssjdjdjd" usStrEnCoding:NSASCIIStringEncoding]];
            break;
        case 25:
            [self.manager POSWriteCommandWithData:[TscCommand qrCodeWithX:p1 andY:p2 andEccLevel:@"M" andCellWidth:p3 andMode:@"H" andRotation:p4 andContent:@"abc.com" usStrEnCoding:NSASCIIStringEncoding]];
            break;
        case 26:
            [self.manager POSWriteCommandWithData:[TscCommand initialPrinter]];
            break;
        case 27:
           // [self.manager PosaddTear:_tf_param1.text];
            break;
        case 28:
            [self.manager POSWriteCommandWithData:[TscCommand cut]];
            break;
        case 29:
            [self.manager POSWriteCommandWithData:[TscCommand print:p1]];
            break;
        case 30:
            [self.manager POSWriteCommandWithData:[TscCommand printWithM:p1 andN:p2]];
            break;
        case 31:
            [self.manager POSWriteCommandWithData:[TscCommand print:p1]];
            break;
            
        default:
            break;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请输入参数变量"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"请输入参数变量";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
