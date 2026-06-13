//
//  XinYeInputVc.h
//  Printer
//
//  Created by apple on 16/3/23.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POSInputVc : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *myScroll;
@property (weak, nonatomic) IBOutlet UILabel *lb_callBack;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (weak, nonatomic) IBOutlet UITextField *tf_param1;
@property (weak, nonatomic) IBOutlet UITextField *tf_param2;
@property (weak, nonatomic) IBOutlet UITextField *tf_param3;
@property (weak, nonatomic) IBOutlet UITextField *tf_param4;
@property (weak, nonatomic) IBOutlet UITextField *tf_param5;
@property (weak, nonatomic) IBOutlet UITextField *tf_param6;
@property (weak, nonatomic) IBOutlet UITextField *tf_param7;
@property (weak, nonatomic) IBOutlet UITextField *tf_param8;
@property (weak, nonatomic) IBOutlet UITextField *tf_param9;


/**
 *  表示第 row 个方法
 */
@property (nonatomic,assign) NSInteger row;
@end
