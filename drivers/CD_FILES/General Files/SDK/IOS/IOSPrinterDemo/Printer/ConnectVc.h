//
//  ConnectVc.h
//  Printer
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface ConnectVc : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *tf_send;

@property (weak, nonatomic) IBOutlet UITextField *tf_host;

@property (weak, nonatomic) IBOutlet UITableView *myTab;

@end
