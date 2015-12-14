//
//  ViewController.h
//  Attend
//
//  Created by Tom Pullen on 26/11/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPGetRequest.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HTTPGetRequestProtocol>

@property (strong, nonatomic) IBOutlet UILabel *checkedInStatusTextField;
@property (strong, nonatomic) IBOutlet UILabel *moduleNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *dateFromToTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) NSMutableArray *beacons;
@property (strong, nonatomic) NSArray *rangedBeacons;

- (void)handleNewRangeOfBeacons;

@end

