//
//  ViewController.m
//  Attend
//
//  Created by Tom Pullen on 26/11/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "HomeViewController.h"
#import "Constants.m"
#import "LoginViewController.h"
#import "ViewAttendanceViewController.h"
#import "HTTPPostRequest.h"
#import "Label.h"

@interface HomeViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) HTTPPostRequest *httpPostRequest;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSString *studentNumber;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSDictionary *currentClassInfo;
@property (strong, nonatomic) NSDate *datetimeOfLastBeaconWipe;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.httpGetRequest.delegate = self;
    self.httpPostRequest.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSString *studentNumber = [[NSUserDefaults standardUserDefaults] stringForKey:STUDENT_NUMBER_KEY];
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    
    // If the user hasn't logged in, send them to the log in screen
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
    [self showNoCurrentClassMessage];
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
    
    CLBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self proximityLabelForBeaconProximity:beacon.proximity];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Minor: %d, Major: %d, UUID: %@",
                                 beacon.minor.intValue, beacon.major.intValue, beacon.proximityUUID.UUIDString];
    
    return cell;
}

#pragma mark - HTTPGetRequest Protocol Methods

// Called when the current class information has been downloaded
- (void)dictionaryDownloaded:(NSDictionary *)dict {
    
    if (dict) {
        
        self.currentClassInfo = dict;
        
        self.moduleNameLabel.text = dict[CURRENT_CLASS_MODULE_NAME_KEY];
        self.dateFromToLabel.text = [NSString stringWithFormat:@"%@-%@", dict[CURRENT_CLASS_START_TIME_KEY], dict[CURRENT_CLASS_FINISH_TIME_KEY]];
        
        // If the student hasn't been recorded as attendance, show this and then record their attendance
        if ([dict[CURRENT_CLASS_ATTENDED_KEY] isEqualToString:@"0"]) {
            
            self.checkedInStatusLabel.text = @"Not checked in";
            self.checkedInStatusLabel.backgroundColor = [UIColor colorWithRed:0.98 green:0.40 blue:0.37 alpha:1.0];
            
            NSDictionary *urlRequestHeaderDictionary = @{REQUEST_HEADER_KEY_TOKEN : self.token};
            
            [self.httpPostRequest sendPOSTRequestWithHeadersDictionary:urlRequestHeaderDictionary atURL:[NSString stringWithFormat:@"%@/attend/student/%@/class/%@", DOMAIN_URL, dict[CURRENT_CLASS_STUDENT_ID_KEY], dict[CURRENT_CLASS_OCCURRENCE_KEY]]];
        } else {
            self.checkedInStatusLabel.text = @"Checked in";
            self.checkedInStatusLabel.backgroundColor = [UIColor colorWithRed:0.48 green:0.63 blue:0.76 alpha:1.0];
        }
        
        [self showTextFields];
    }
}

#pragma mark - HTTPPostRequest Protocol Methods

// Will be called when the attendance has been recorded
- (void)httpStatusCodeReturned:(NSString *)httpHtatusCode {
    
    // If the status code returned for the attend POST request, the attendance has successfully been recorded
    if ([httpHtatusCode isEqualToString:@"204"]) {
        self.checkedInStatusLabel.text = @"Checked in";
        self.checkedInStatusLabel.backgroundColor = [UIColor colorWithRed:0.48 green:0.63 blue:0.76 alpha:1.0];
        
        [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"Checked into %@", self.currentClassInfo[CURRENT_CLASS_MODULE_NAME_KEY]]];
        NSLog(@"Checked into %@", self.currentClassInfo[CURRENT_CLASS_MODULE_NAME_KEY]);
    }
    
}

#pragma mark - Helper Methods

- (IBAction)viewAttendanceButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showViewAttendanceVC" sender:nil];
}

- (void)handleNewRangeOfBeacons {
        
    // For every x amount of seconds, clear the local array of beacons
    if (-[self.datetimeOfLastBeaconWipe timeIntervalSinceNow] > BEACON_ARRAY_REFRESH_RATE) {
        self.beacons = [[NSMutableArray alloc] init];
        self.datetimeOfLastBeaconWipe = [[NSDate alloc] init];
        if ([self currentClassHasEnded]) {
            [self showNoCurrentClassMessage];
        }
    }
    
    // For every ranged beacon, if we haven't already ranged it, add it to our local array and see if the current student has a class for that beacon
    for (CLBeacon *beacon in self.rangedBeacons) {
        
        if (![self array:self.beacons containsBeacon:beacon]) {
            [self.beacons addObject:beacon];
            
            NSDictionary *urlRequestHeaderDictionary =
                @{
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
    [self.dateFromToLabel setHidden:NO];
}

- (void)hideTextFields {
    [self.checkedInStatusLabel setHidden:YES];
    [self.dateFromToLabel setHidden:YES];
}

- (void)sendLocalNotificationWithMessage:(NSString*)message {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)currentClassHasEnded {
    
    NSDate *currentClassFinishDate = [self todaysDateWithSpecifiedTimeFromString:self.currentClassInfo[CURRENT_CLASS_FINISH_TIME_KEY]];
    
    // If the current class finish time is less than or equal to the current time, the class has ended
    if ([currentClassFinishDate compare:[NSDate date]] != NSOrderedDescending) {
        return YES;
    }
    
    return NO;
}

- (NSDate *)todaysDateWithSpecifiedTimeFromString:(NSString *)time {
    // Split the time string (HH:mm) into hour and minute strings
    NSArray *array = [time componentsSeparatedByString:@":"];
    
    // Get year, month and day values of today:
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *date = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    // Set the hour and minute values from the given time string
    [date setHour:[array[0] integerValue]];
    [date setMinute:[array[1] integerValue]];
    
    return [calendar dateFromComponents:date];
}

- (void)showNoCurrentClassMessage {
    
    self.moduleNameLabel.text = @"No current class for any beacons within range.";
    [self hideTextFields];
}

- (NSString *)proximityLabelForBeaconProximity:(CLProximity)beaconProximity {
    
    NSString *proximityLabel = @"";
    
    switch (beaconProximity) {
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
    
    return proximityLabel;
}

#pragma mark - Lazy Instantiation

- (HTTPGetRequest *)httpGetRequest {
    if (!_httpGetRequest) {
        _httpGetRequest = [[HTTPGetRequest alloc] init];
    }
    
    return _httpGetRequest;
}

- (HTTPPostRequest *)httpPostRequest {
    if (!_httpPostRequest) {
        _httpPostRequest = [[HTTPPostRequest alloc] init];
    }
    
    return _httpPostRequest;
}

- (NSMutableArray *)beacons {
    if (!_beacons) {
        _beacons = [[NSMutableArray alloc] init];
    }
    
    return _beacons;
}

- (NSDictionary *)classInfo {
    if (!_currentClassInfo) {
        _currentClassInfo = [[NSDictionary alloc] init];
    }
    
    return _currentClassInfo;
}

- (NSDate *)datetimeOfLastBeaconWipe {

    if (!_datetimeOfLastBeaconWipe) {
        _datetimeOfLastBeaconWipe = [[NSDate alloc] init];
    }
    
    return _datetimeOfLastBeaconWipe;
    
}

@end
