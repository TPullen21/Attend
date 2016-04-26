//
//  HTTPPostRequest.m
//  Attend
//
//  Created by Tom Pullen on 14/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import "HTTPPostRequest.h"
#import "Constants.m"

@interface HTTPPostRequest()

@property (strong, nonatomic) NSMutableData *downloadedData;

@end

@implementation HTTPPostRequest

+ (void)sendPOSTRequestWithHeadersDictionary:(NSDictionary *)dictionary atURL:(NSString *)url {
    
    NSMutableURLRequest *postRequest= [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    [postRequest setHTTPMethod:@"POST"];
    
    for (NSString *key in [dictionary allKeys]) {
        [postRequest addValue:dictionary[key] forHTTPHeaderField:key];
    }
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSString *responseText = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding];
            NSLog(@"Response: %@", responseText);
        }
    }];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Initialize the data object
    self.downloadedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the newly downloaded data
    [self.downloadedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Post request failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:self.downloadedData encoding: NSASCIIStringEncoding];
    NSLog(@"Response Text: %@", responseText);
    
}

@end
