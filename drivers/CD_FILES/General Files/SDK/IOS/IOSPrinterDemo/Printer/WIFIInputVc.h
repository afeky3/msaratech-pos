//
//  WIFIInputVc.h
//  Printer
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POSWIFIManager.h"
#import "ImageTranster.h"
#import "TscCommand.h"
@interface WIFIInputVc : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *myTextview;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,strong) POSWIFIManager *manager;

@property (weak, nonatomic) IBOutlet UITextField *tf_param1;
@property (weak, nonatomic) IBOutlet UITextField *tf_param2;
@property (weak, nonatomic) IBOutlet UITextField *tf_param3;
@property (weak, nonatomic) IBOutlet UITextField *tf_param4;
@property (weak, nonatomic) IBOutlet UITextField *tf_param5;
@property (weak, nonatomic) IBOutlet UITextField *tf_param6;
@property (weak, nonatomic) IBOutlet UITextField *tf_param7;
@property (weak, nonatomic) IBOutlet UITextField *tf_param8;
@property (weak, nonatomic) IBOutlet UITextField *tf_param9;

@end
