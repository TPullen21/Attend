//
//  LoginViewController.m
//  Attend
//
//  Created by Tom Pullen on 14/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.m"

static int const LARGE_PRIME = 15485863;
static int const DIVISOR = 899999;
static int const CONSTANT = 100000;

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.incorrectValuesLabel.hidden = YES;
}

- (IBAction)loginButtonPressed:(id)sender {
    NSString *studentNumber = self.studentNumberTextField.text;
    NSString *token = self.tokenTextField.text;
    
    if (studentNumber.length == 8 && token.length == 6) {
        if ([self tokenIsCorrect:token forStudentNumber:studentNumber]) {
            self.incorrectValuesLabel.hidden = YES;
            [[NSUserDefaults standardUserDefaults] setObject:studentNumber forKey:STUDENT_NUMBER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            self.tokenTextField.text = @"";
            self.incorrectValuesLabel.hidden = NO;
        }
    } else {
        self.tokenTextField.text = @"";
        self.incorrectValuesLabel.hidden = NO;
    }
}

- (BOOL)tokenIsCorrect:(NSString *)token forStudentNumber:(NSString *)studentNumber {
    return [token isEqualToString:[self hashStudentNumber:studentNumber]];
}

- (NSString *)hashStudentNumber:(NSString *)studentNumberString {
    
    int studentNumber = [studentNumberString intValue];
    
    int hashedStudentNumber = ((((unsigned long)studentNumber * LARGE_PRIME)) % DIVISOR) + CONSTANT;
    
    return [NSString stringWithFormat:@"%i", hashedStudentNumber];
}

@end
