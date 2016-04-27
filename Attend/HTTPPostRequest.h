//
//  HTTPPostRequest.h
//  Attend
//
//  Created by Tom Pullen on 14/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPPostRequestProtocol <NSObject>

- (void)httpStatusCodeReturned:(NSString *)httpStatusCode;

@end

@interface HTTPPostRequest : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<HTTPPostRequestProtocol> delegate;

- (void)sendPOSTRequestWithHeadersDictionary:(NSDictionary *)dictionary atURL:(NSString *)url;

@end
