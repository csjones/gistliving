//
//  JSONModel.m
//  gistliving
//
//  Created by crkmnstr on 1/17/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

#import "JSONModel.h"
#import "AFJSONRequestOperation.h"

@implementation JSONModel

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setParameterEncoding:AFJSONParameterEncoding];
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSONModel

- (void)getJSONData
{
    [self getPath:@"feed.json"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id json) {
              _jsonArray = [NSArray arrayWithArray:json];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"jsonSuccess" object:nil];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@",error);
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"jsonError" object:nil];
          }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Singleton

+ (JSONModel*)sharedInstance
{
    static JSONModel *sharedInstance = nil;
    
    if(sharedInstance)
        return sharedInstance;
    
    static dispatch_once_t pred;	// Lock
    
    dispatch_once(&pred,
                  ^{	// This code is called at most once per app
                      sharedInstance = [[JSONModel alloc] initWithBaseURL:[NSURL URLWithString:@"http://warm-eyrie-4354.herokuapp.com/"]];
                  });
    
    return sharedInstance;
}

@end
