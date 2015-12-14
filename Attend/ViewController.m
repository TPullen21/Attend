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

@interface ViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    
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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginVC = segue.destinationViewController;
    }
    
    NSLog(@"segue identififer = %@",segue.identifier);
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
        NSString *message = [NSString stringWithFormat:@"Module: %@ Class type: %@ Start: %@ Finish %@", dict[@"module_name"], dict[@"class_type"], dict[@"start_datetime"], dict[@"finish_datetime"] ];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in!"
                                                        message:message
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Helper Methods

- (void)handleNewRangeOfBeacons {
    for (CLBeacon *beacon in self.rangedBeacons) {
        if (![self array:self.beacons containsBeacon:beacon]) {
            [self.beacons addObject:beacon];
            [self.httpGetRequest downloadJSONArrayWithURL:[NSString stringWithFormat:@"%@/getStudentsClassFromBeacon.php?studentNumber=%@&ibMajor=%@&ibMinor=%@", DOMAIN_URL, studentNumber, [beacon.major stringValue], [beacon.minor stringValue]]];
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

@end
