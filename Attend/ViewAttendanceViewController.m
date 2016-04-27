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
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
