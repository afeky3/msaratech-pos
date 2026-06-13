//
//  TSCCommandVc.h
//  Printer
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POSWIFIManager.h"
#import "TscCommand.h"
#import "PosCommand.h"

@interface TSCCommandVc : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *tf_param;
@property (weak, nonatomic) IBOutlet UITableView *myTab;
@property (nonatomic,strong) POSWIFIManager *manager;
@end
