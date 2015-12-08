//
//  HTTPGetRequest.m
//  Attend
//
//  Created by Tom Pullen on 08/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import "HTTPGetRequest.h"

@interface HTTPGetRequest()

@property (strong, nonatomic) NSMutableData *downloadedData;

@end

@implementation HTTPGetRequest

- (void)downloadJSONArrayWithURL:(NSString *)url {
    // Download the json file
    NSURL *jsonFileUrl = [NSURL URLWithString:url];
    
    // Create the request
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:jsonFileUrl];
    
    // Create the NSURLConnection
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma mark NSURLConnectionDataProtocol Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Initialize the data object
    self.downloadedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the newly downloaded data
    [self.downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSError *error;
    
    NSArray *jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingAllowFragments error:&error];
    
    // Ready to notify delegate that data is ready and pass back items
    if (self.delegate) {
        [self.delegate arrayDownloaded:jsonArray];
    }
}


@end
