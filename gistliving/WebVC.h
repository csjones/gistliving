//
//  WebVC.h
//  gistliving
//
//  Created by crkmnstr on 1/21/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

@interface WebVC : UIViewController
{
    IBOutlet UIWebView *_webView;
}

@property (nonatomic,strong)    NSURLRequest    *urlRequest;

@end
