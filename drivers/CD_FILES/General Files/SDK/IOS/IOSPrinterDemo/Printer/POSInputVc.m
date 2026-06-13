//
//  XinYeInputVc.m
//  Printer
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "POSInputVc.h"
#import "POSBLEManager.h"

@interface POSInputVc ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tf_printer;
@end

@implementation POSInputVc

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTextView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.myTextView.layer.borderWidth = 0.5;
    
    [[POSBLEManager sharedInstance] POSSetDataCodingType:NSUTF8StringEncoding]; //设置UTF－8编码模式，此处也可以改成其他模式
}

/**
    打印
 */
- (IBAction)printBtnClick:(id)sender {
    [[POSBLEManager sharedInstance] POSsendDataToPeripheral:[POSBLEManager sharedInstance].writePeripheral dataString:_tf_printer.text];
}

//// 发送
- (IBAction)sendMessageToPrinter:(id)sender {
//    
//    int p1 = _tf_param1.text.intValue;
//    int p2 = _tf_param2.text.intValue;
//    int p3 = _tf_param3.text.intValue;
//    int p4 = _tf_param4.text.intValue;
//    int p5 = _tf_param5.text.intValue;
//    int p6 = _tf_param6.text.intValue;
//    int p7 = _tf_param7.text.intValue;
//    int p8 = _tf_param8.text.intValue;
//    int p9 = _tf_param9.text.intValue;
//    
//    NSString *str = [self.myTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSArray *strArr = [str componentsSeparatedByString:@","];
//
//    if (self.row == 5) {
//        [[PosBLEManager sharedInstance] PosUpdataPrinterState:p1 completion:^(CBCharacteristic *character){
//            
//            [self setPrintCallBack:character];
//            
//            NSLog(@"row =%zd====%@",_row,character.value);
//        }];
//    }else if (_row == 6) {
//        [[PosBLEManager sharedInstance] PosUpdataPrinterAnswer:p1];
//    }else if (_row == 7) {
//        [[PosBLEManager sharedInstance] PosOpenBoxAndPulse:p1 m:p2 t:p3];
//    }else if (_row == 9) {
//        [[PosBLEManager sharedInstance] PosSetCharRightMargin:p1];
//    }else if (_row == 10) {
//        [[PosBLEManager sharedInstance] PosSelectPrintModel:p1];
//    }else if (_row == 11) {
//        [[PosBLEManager sharedInstance] PosSetPrintLocationWithParam:p1 nH:p2];
//    }else if (_row == 12) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelCustomCharacter:p1];
//    }else if (_row == 13){ 
//        [[PosBLEManager sharedInstance] PosDefinCustomCharacter:p1 c1:p2 c2:p3 dx:strArr];
//    }else if (_row == 14) {
//        [[PosBLEManager sharedInstance] PosSelectBitmapModel:p1 nL:p2 nH:p3 dx:strArr];
//    }else if (_row == 15) {
//        [[PosBLEManager sharedInstance] PosCancelUnderLineModelWith:p1];
//    }else if (_row == 17) {
//        [[PosBLEManager sharedInstance] PosSetLineMarginWith:p1];
//    }else if (_row == 18) {
//        [[PosBLEManager sharedInstance] PosSelectPrinterWith:p1];
//    }else if (_row == 19) {
//        [[PosBLEManager sharedInstance] PosCancelCustomCharacterWith:p1];
//    }else if (_row == 21){
//        [[PosBLEManager sharedInstance] PosSetTabLocationWith:strArr];
//    }else if (_row == 22) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelBoldModelWith:p1];
//    }else if (_row == 23) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelDoublePrintModel:p1];
//    }else if (_row == 24) {
//        [[PosBLEManager sharedInstance] PosPrintAndPushPageWith:p1];
//    }else if (_row == 26) {
//        [[PosBLEManager sharedInstance] PosSelectFontWith:p1];
//    }else if (_row == 27) {
//        [[PosBLEManager sharedInstance] PosSelectINTL_CHAR_SETWith:p1];
//    }else if (_row == 29) {
//        [[PosBLEManager sharedInstance] PosSelectPrintDirectionOnPageModel:p1];
//    }else if (_row == 30) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelRotationClockwise:p1];
//    }else if (_row == 31) {
//        [[PosBLEManager sharedInstance] PosSetprintLocationOnPageModelWithXL:p1 xH:p2 yL:p3 yH:p4 dxL:p5 dxH:p6 dyL:p7 dyH:p8];
//    }else if (_row == 32) {
//        [[PosBLEManager sharedInstance] PosSetHorizonLocationWith:p1 nH:p2];
//    }else if (_row == 33) {
//        [[PosBLEManager sharedInstance] PosSelectAlignmentWithN:p1];
//    }else if (_row == 34) {
//        [[PosBLEManager sharedInstance] PosSelectSensorForOutputSignal:p1];
//    }else if (_row == 35) {
//        [[PosBLEManager sharedInstance] PosSelectSensorForStopPrint:p1];
//    }else if (_row == 36) {
//        [[PosBLEManager sharedInstance] PosAllowOrDisableKeypress:p1];
//    }else if (_row == 37) {
//        [[PosBLEManager sharedInstance] PosPrintAndPushPageRow:p1];
//    }else if (_row == 38) {
//        [[PosBLEManager sharedInstance] PosMakePulseWithCashboxWithM:p1 t1:p2 t2:p3];
//    }else if (_row == 39) {
//        [[PosBLEManager sharedInstance] PosSelectCharacterTabN:p1];
//    }else if (_row == 40) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelInversionPrintModel:p1];
//    }else if (_row == 41) {
//        [[PosBLEManager sharedInstance] PosPrintFlashBitmapWithN:p1 m:p2];
//    }else if (_row == 42) {
//        [[PosBLEManager sharedInstance] PosDefinFlashBitmapWithN:p1 Points:strArr];
//    }else if (_row == 43) {
//        [[PosBLEManager sharedInstance] PosSelectCharacterSize:p1];
//    }else if (_row == 44) {
//        [[PosBLEManager sharedInstance] PosSetVertLocationOnPageModelWithnL:p1 nH:p2];
//    }else if (_row == 45) {
//        [[PosBLEManager sharedInstance] PosDefineLoadBitmapWithX:p1 Y:p2 Points:strArr];
//    }else if (_row == 46) {
//        [[PosBLEManager sharedInstance] PosPrintDataAndSaveAsHexWithpL:p1 pH:p2 n:p3 m:p4];
//    }else if (_row == 47) {
//        [[PosBLEManager sharedInstance] PosPrintLoadBitmapM:p1];
//    }else if (_row == 49) {
//        [[PosBLEManager sharedInstance] PosSelectORCancelBWPrintModel:p1];
//    }else if (_row == 50) {
//        [[PosBLEManager sharedInstance] PosSelectHRIPrintLocation:p1];
//    }else if (_row == 51) {
//        [[PosBLEManager sharedInstance] PosSetLeftMarginWithnL:p1 nH:p2];
//    }else if (_row == 52) {
//        [[PosBLEManager sharedInstance] PosSetHoriAndVertUnitXWith:p1 y:p2];
//    }else if (_row == 53) {
//        [[PosBLEManager sharedInstance] PosSelectCutPaperModelAndCutPaperWith:p1 n:p2 selectedModel:p3];
//    }else if (_row == 54) {
//        [[PosBLEManager sharedInstance] PosSetPrintLocationWith:p1 nH:p2];
//    }else if (_row == 55) {
//        [[PosBLEManager sharedInstance] PosSetVertRelativeLocationOnPageModelWith:p1 nH:p2];
//    }else if (_row == 56) {
//        [[PosBLEManager sharedInstance] PosRunMacroMommandWith:p1 t:p2 m:p3];
//    }else if (_row == 57) {
//        [[PosBLEManager sharedInstance] PosOpenOrCloseASB:p1];
//    }else if (_row == 58) {
//        [[PosBLEManager sharedInstance] PosSelectHRIFontToUse:p1];
//    }else if (_row == 59) {
//        [[PosBLEManager sharedInstance] PosSelectBarcodeHeight:p1];
//    }else if (_row == 60) {
//        [[PosBLEManager sharedInstance] PosPrintBarCodeWithPoints:p1 n:p2 points:strArr selectModel:p3];
//    }else if (_row == 61) {
//        [[PosBLEManager sharedInstance] PosCallBackStatus:p1 completion:^(CBCharacteristic *character) {
//            [self setPrintCallBack:character];
//        }];
//    }else if (_row == 62) {
//        [[PosBLEManager sharedInstance] PosPrintRasterBitmapWith:p1 xL:p2 xH:p3 yl:p4 yh:p5 points:strArr];
//    }else if (_row == 63) {
//        [[PosBLEManager sharedInstance] PosSetBarcodeWidth:p1];
//    }else if (_row == 64) {
//        [[PosBLEManager sharedInstance] PosSetChineseCharacterModel:p1];
//    }else if (_row == 66) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelChineseUderlineModel:p1];
//    }else if (_row == 68) {
//        [[PosBLEManager sharedInstance] PosDefineCustomChinesePointsC1:p1 c2:p2 points:strArr];
//    }else if (_row == 69) {
//        [[PosBLEManager sharedInstance] PosSetChineseMarginWithLeftN1:p1 n2:p2];
//    }else if (_row == 70) {
//        [[PosBLEManager sharedInstance] PosSelectOrCancelChineseHModelAndWModel:p1];
//    }else if (_row == 72) {
//        [[PosBLEManager sharedInstance] PosPrinterSound:p1 t:p2];
//    }else if (_row == 73) {
//        [[PosBLEManager sharedInstance] PosPrinterSoundAndAlarmLight:p1 t:p2 n:p3];
//    }
//    
}

- (void)setPrintCallBack:(CBCharacteristic *)character {
    
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"HH:mm:ss";
    NSString *date = [form stringFromDate:[NSDate date]];
    self.lb_callBack.text = [[NSString stringWithFormat:@"%@ : %@ \n",date,character.value] stringByAppendingString:self.lb_callBack.text];
    [self.lb_callBack sizeToFit];
    self.myScroll.contentSize = CGSizeMake(0, self.lb_callBack.frame.size.height);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请输入指令变量参数，参数与参数之间用','隔开"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"请输入指令变量参数，参数与参数之间用','隔开";
        textView.textColor = [UIColor lightGrayColor];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
    }
    return YES;
}
@end
