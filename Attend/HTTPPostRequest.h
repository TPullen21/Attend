//
//  HTTPPostRequest.h
//  Attend
//
//  Created by Tom Pullen on 14/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPPostRequest : NSObject <NSURLConnectionDataDelegate>

+ (void)sendPOSTRequestWithDictionary:(NSDictionary *)dictionary atURL:(NSString *)url;

@end
