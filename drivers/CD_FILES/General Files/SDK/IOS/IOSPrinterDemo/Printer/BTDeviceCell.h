//
//  BTDeviceCell.h
//  print
//
//  Created by ding on 2019/11/4.
//  Copyright © 2019 ding. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTDeviceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *RSSI;
@property (strong, nonatomic) IBOutlet UILabel *NAME;
@property (strong, nonatomic) IBOutlet UILabel *UUID;

@end

NS_ASSUME_NONNULL_END
