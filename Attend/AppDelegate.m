//
//  AppDelegate.m
//  Attend
//
//  Created by Tom Pullen on 26/11/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:@"F8AD3E82-0D91-4D9B-B5C7-7324744B2026"];
    NSString *regionIdentifier = @"pullen.BeaconModules";
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
    
    // Log the authorization status of being able to use the user's location
    NSLog(@"%@", [self authorizationStatus]);
    
    // Initialise and set up the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    [self.locationManager startUpdatingLocation];
    
    // Ask for notifications authorisation, if not already authorised
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

#pragma mark - CLLocationManager Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
    
    NSString *enterMessage = @"You entered the region";
    NSLog(@"%@", enterMessage);
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager stopUpdatingLocation];
    
    NSString *exitMessage = @"You left the region";
    NSLog(@"%@", exitMessage);
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    HomeViewController *viewController = (HomeViewController*)self.window.rootViewController;
    viewController.rangedBeacons = beacons;
    [viewController handleNewRangeOfBeacons];
    [viewController.tableView reloadData];
    
    // Log to the debug console the proximity of the nearest beacon, if any
    if(beacons.count > 0) {
        [self logProximityOfNearestBeacon:beacons];
    } else {
        NSLog(@"No beacons are nearby");
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // Get the application's state
    UIApplicationState state = [application applicationState];
    
    // If the application is currently being used, create a UI Alert for the notification
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attend"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Helper Methods

- (NSString *)authorizationStatus {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"Authorization Status: Authorized Always";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return @"Authorization Status: Authorized when in use";
            break;
        case kCLAuthorizationStatusDenied:
            return @"Authorization Status: Denied";
            break;
        case kCLAuthorizationStatusNotDetermined:
            return @"Authorization Status: Not determined";
            break;
        case kCLAuthorizationStatusRestricted:
            return @"Authorization Status: Restricted";
            break;
            
        default:
            break;
    }
    
    return @"";
}

- (void)logProximityOfNearestBeacon:(NSArray *)beacons {
    
    NSString *message = @"";
    
    CLBeacon *nearestBeacon = beacons.firstObject;
    if(nearestBeacon.proximity == self.lastProximity ||
       nearestBeacon.proximity == CLProximityUnknown) {
        return;
    }
    self.lastProximity = nearestBeacon.proximity;
    
    switch(nearestBeacon.proximity) {
        case CLProximityFar:
            message = @"You are far away from the beacon";
            break;
        case CLProximityNear:
            message = @"You are near the beacon";
            break;
        case CLProximityImmediate:
            message = @"You are in the immediate proximity of the beacon";
            break;
        case CLProximityUnknown:
            return;
    }
    
    NSLog(@"%@", message);
}

#pragma mark - Unimplemented Default Methods

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
