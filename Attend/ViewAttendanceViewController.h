//
//  ViewAttendanceViewController.h
//  Attend
//
//  Created by Tom Pullen on 29/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewAttendanceViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSString *studentNumber;
@property (strong, nonatomic) NSString *token;

@end
