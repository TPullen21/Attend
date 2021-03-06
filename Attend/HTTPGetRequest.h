//
//  HTTPGetRequest.h
//  Attend
//
//  Created by Tom Pullen on 08/12/2015.
//  Copyright © 2015 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPGetRequestProtocol <NSObject>

- (void)dictionaryDownloaded:(NSDictionary *)dict;

@end

@interface HTTPGetRequest : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<HTTPGetRequestProtocol> delegate;

- (void)downloadJSONArrayWithURL:(NSString *)url withDictionaryForHeaders:(NSDictionary *)headerDictionary;

@end
