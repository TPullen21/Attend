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

@property (strong, nonatomic) NSString *httpStatusCode;

@end

@implementation HTTPPostRequest

- (void)sendPOSTRequestWithHeadersDictionary:(NSDictionary *)dictionary atURL:(NSString *)url {
    
    NSMutableURLRequest *postRequest= [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    [postRequest setHTTPMethod:@"POST"];
    
    for (NSString *key in [dictionary allKeys]) {
        [postRequest addValue:dictionary[key] forHTTPHeaderField:key];
    }
    
    [NSURLConnection connectionWithRequest:postRequest delegate:self];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (response) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        self.httpStatusCode = [NSString stringWithFormat:@"%li", (long)[httpResponse statusCode]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Post request failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.delegate) {
        [self.delegate httpStatusCodeReturned:self.httpStatusCode];
    }
    
}

@end
