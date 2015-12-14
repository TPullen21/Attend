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

+ (void)sendPOSTRequestWithDictionary:(NSDictionary *)dictionary atURL:(NSString *)url {
    
    NSMutableURLRequest *postRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0];
    
    NSError *error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    [postRequest setHTTPMethod:@"POST"];
    
    [postRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // should check for and handle errors here but we aren't
    [postRequest setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            //do something with error
        } else {
            NSString *responseText = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding];
            NSLog(@"Response: %@", responseText);
            
            NSString *newLineStr = @"\n";
            responseText = [responseText stringByReplacingOccurrencesOfString:@"<br />" withString:newLineStr];
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
