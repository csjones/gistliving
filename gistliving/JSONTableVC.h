//
//  JSONTableVC.h
//  gistliving
//
//  Created by crkmnstr on 1/17/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

@class JSONModel;

@interface JSONTableVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    JSONModel   *_jsonModel;
    
    NSCache     *_imageCache;
    
    unsigned    _retryCounter;
    
    NSIndexPath *_selectedIndexPath;
}

@end
