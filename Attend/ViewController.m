//
//  ViewController.m
//  Attend
//
//  Created by Tom Pullen on 26/11/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "Constants.m"
#import "LoginViewController.h"
#import "HTTPPostRequest.h"
#import "Label.h"

@interface ViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSString *studentNumber;
@property (strong, nonatomic) NSDictionary *classInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.httpGetRequest.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSString *studentNumber = [[NSUserDefaults standardUserDefaults] stringForKey:STUDENT_NUMBER_KEY];
    
    if (!studentNumber) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    else {
        self.studentNumber = studentNumber;
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self hideTextFields];
    ((Label *)self.moduleNameLabel).verticalAlignment = UIControlContentVerticalAlignmentBottom;
}

#pragma mark - Table View Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beaconCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"beaconCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CLBeacon *beacon = (CLBeacon*)[self.beacons objectAtIndex:indexPath.row];
    NSString *proximityLabel = @"";
    switch (beacon.proximity) {
        case CLProximityFar:
            proximityLabel = @"Far";
            break;
        case CLProximityNear:
            proximityLabel = @"Near";
            break;
        case CLProximityImmediate:
            proximityLabel = @"Immediate";
            break;
        case CLProximityUnknown:
            proximityLabel = @"Unknown";
            break;
    }
    
    cell.textLabel.text = proximityLabel;
    
    NSString *detailLabel = [NSString stringWithFormat:@"Major: %d, Minor: %d, RSSI: %d, UUID: %@",
                             beacon.major.intValue, beacon.minor.intValue, (int)beacon.rssi, beacon.proximityUUID.UUIDString];
    cell.detailTextLabel.text = detailLabel;
    
    return cell;
}

#pragma mark - HTTPGetRequest Protocol Methods

- (void)arrayDownloaded:(NSArray *)array {
    NSDictionary *dict = [array firstObject];
    
    if (dict) {
        
        self.moduleNameLabel.text = dict[@"module_name"];
        self.dateFromToLabel.text = [NSString stringWithFormat:@"%@-%@", dict[@"start_time"], dict[@"finish_time"]];
        
        self.classInfo = dict;
        
        if ([dict[@"attended"] isEqualToString:@"0"]) {
            
            [HTTPPostRequest sendPOSTRequestWithDictionary:@{
                                                             @"studentID" : dict[@"student_id"],
                                                             @"occurrenceID" : dict[@"occurrence_id"]
                                                             } atURL:[NSString stringWithFormat:@"%@/recordAttendance.php", DOMAIN_URL]];
            
            [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"Checked into %@", dict[@"module_name"]]];
            
            self.checkedInStatusLabel.text = @"Checked in";
            self.checkedInStatusLabel.backgroundColor = [UIColor colorWithRed:0.48 green:0.63 blue:0.76 alpha:1.0];
        } else {
            self.checkedInStatusLabel.text = @"Not checked in";
            self.checkedInStatusLabel.backgroundColor = [UIColor colorWithRed:0.98 green:0.40 blue:0.37 alpha:1.0];
        }
        
        [self showTextFields];
        
//        NSString *message = [NSString stringWithFormat:@"Module: %@ Class type: %@ Start: %@ Finish %@", dict[@"module_name"], dict[@"class_type"], dict[@"start_datetime"], dict[@"finish_datetime"] ];
//        
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in!"
//                                                        message:message
//                                                       delegate:self cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
}

#pragma mark - Helper Methods

- (void)handleNewRangeOfBeacons {
    for (CLBeacon *beacon in self.rangedBeacons) {
        if (![self array:self.beacons containsBeacon:beacon]) {
            [self.beacons addObject:beacon];
            [self.httpGetRequest downloadJSONArrayWithURL:[NSString stringWithFormat:@"%@/getStudentsClassFromBeacon.php?studentNumber=%@&ibMajor=%@&ibMinor=%@", DOMAIN_URL, self.studentNumber, [beacon.major stringValue], [beacon.minor stringValue]]];
        }
    }
}

- (BOOL)array:(NSArray *)array containsBeacon:(CLBeacon *)beacon {
    BOOL containsBeacon = NO;
    
    for (CLBeacon *currentBeaconInArray in array) {
        if ([currentBeaconInArray.major isEqualToNumber:beacon.major] && [currentBeaconInArray.minor isEqualToNumber:beacon.minor]) {
            return YES;
        }
    }
    
    return containsBeacon;
}

- (void)showTextFields {
    [self.checkedInStatusLabel setHidden:NO];
    [self.moduleNameLabel setHidden:NO];
    [self.dateFromToLabel setHidden:NO];
}

- (void)hideTextFields {
    [self.checkedInStatusLabel setHidden:YES];
    [self.moduleNameLabel setHidden:YES];
    [self.dateFromToLabel setHidden:YES];
}

- (void)sendLocalNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - Lazy Instantiation

- (HTTPGetRequest *)httpGetRequest {
    if (!_httpGetRequest) {
        _httpGetRequest = [[HTTPGetRequest alloc] init];
    }
    
    return _httpGetRequest;
}

- (NSMutableArray *)beacons {
    if (!_beacons) {
        _beacons = [[NSMutableArray alloc] init];
    }
    
    return _beacons;
}

- (NSDictionary *)classInfo {
    if (!_classInfo) {
        _classInfo = [[NSDictionary alloc] init];
    }
    
    return _classInfo;
}

@end
