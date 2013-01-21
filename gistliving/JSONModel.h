//
//  JSONModel.h
//  gistliving
//
//  Created by crkmnstr on 1/17/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

#import "AFHTTPClient.h"

@interface JSONModel : AFHTTPClient

@property   (nonatomic,readonly)    NSArray *jsonArray;

+ (id)sharedInstance;

- (void)getJSONData;

@end
