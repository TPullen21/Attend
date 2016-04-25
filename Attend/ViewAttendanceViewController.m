//
//  ViewAttendanceViewController.m
//  Attend
//
//  Created by Tom Pullen on 29/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "ViewAttendanceViewController.h"
#import "Constants.m"

@interface ViewAttendanceViewController ()

@end

@implementation ViewAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/student/%@/token/%@", WEB_APP_URL, self.studentNumber, self.token];
    NSLog(urlString);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    //self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
