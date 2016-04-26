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
#import "ViewAttendanceViewController.h"
#import "HTTPPostRequest.h"
#import "Label.h"

@interface ViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSString *studentNumber;
@property (strong, nonatomic) NSString *token;
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
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    
    if (!studentNumber || !token) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    else {
        self.studentNumber = studentNumber;
        self.token = token;
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideTextFields];
    ((Label *)self.moduleNameLabel).verticalAlignment = UIControlContentVerticalAlignmentBottom;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ViewAttendanceViewController class]] ) {
        ViewAttendanceViewController *viewAttendanceVC = segue.destinationViewController;
        viewAttendanceVC.studentNumber = self.studentNumber;
        viewAttendanceVC.token = self.token;
    }
}

#pragma mark - Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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

- (void)arrayDownloaded:(NSDictionary *)array {
    //NSDictionary *dict = [array firstObject];
    NSDictionary *dict = array;
    if (dict) {
        
        self.moduleNameLabel.text = dict[@"module_name"];
        self.dateFromToLabel.text = [NSString stringWithFormat:@"%@-%@", dict[@"start_time"], dict[@"finish_time"]];
        
        self.classInfo = dict;
        
        if ([dict[@"attended"] isEqualToString:@"0"]) {
            
            NSDictionary *urlRequestHeaderDictionary = @{REQUEST_HEADER_KEY_TOKEN : self.token};
            
            [HTTPPostRequest sendPOSTRequestWithHeadersDictionary:urlRequestHeaderDictionary atURL:[NSString stringWithFormat:@"%@/attend/student/%@/class/%@", DOMAIN_URL, dict[@"student_id"], dict[@"occurrence_id"]]];
            
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

- (IBAction)viewAttendanceButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showViewAttendanceVC" sender:nil];
}

- (void)handleNewRangeOfBeacons {
    for (CLBeacon *beacon in self.rangedBeacons) {
        if (![self array:self.beacons containsBeacon:beacon]) {
            [self.beacons addObject:beacon];
            
            NSDictionary *urlRequestHeaderDictionary = @{
                                                         REQUEST_HEADER_KEY_TOKEN : self.token,
                                                         REQUEST_HEADER_KEY_BEACON_MINOR : [beacon.minor stringValue],
                                                         REQUEST_HEADER_KEY_BEACON_MAJOR : [beacon.major stringValue]
                                                        };
            
            [self.httpGetRequest downloadJSONArrayWithURL:[NSString stringWithFormat:@"%@%@/%@", DOMAIN_URL, STUDENT_CLASS_INFO_ROUTE, self.studentNumber] withDictionaryForHeaders:urlRequestHeaderDictionary];
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
