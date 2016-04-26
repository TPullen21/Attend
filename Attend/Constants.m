//
//  Constants.m
//  Attend
//
//  Created by Tom Pullen on 08/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString *const DOMAIN_URL = @"http://itsuite.it.brighton.ac.uk/torp10/attend";
//static NSString *const DOMAIN_URL = @"http://pullen.co.uk/development/attend";
static NSString *const DOMAIN_URL = @"http://ec2-52-16-135-99.eu-west-1.compute.amazonaws.com:8888";
static NSString *const WEB_APP_URL = @"http://attend.meteorapp.com/studentportal";


static NSString *const STUDENT_CLASS_INFO_ROUTE = @"/attendance/currentClass/student";


static NSString *const STUDENT_NUMBER_KEY = @"student_number";
static NSString *const TOKEN_KEY = @"token_number";

static NSString *const REQUEST_HEADER_KEY_TOKEN = @"token";
static NSString *const REQUEST_HEADER_KEY_BEACON_MINOR = @"beacon_minor";
static NSString *const REQUEST_HEADER_KEY_BEACON_MAJOR = @"beacon_major";
