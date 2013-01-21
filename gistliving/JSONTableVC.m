//
//  JSONTableVC.m
//  gistliving
//
//  Created by crkmnstr on 1/17/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

#import "WebVC.h"
#import "JSONModel.h"
#import "JSONTableVC.h"
#import "ZAActivityBar.h"
#import "UIImage+Resize.h"
#import "UIImageView+AFNetworking.h"
#import "PrettyCustomViewTableViewCell.h"

@interface JSONTableVC ()

- (void)reloadData:(NSNotification *)notification;
- (void)retryGettingJSON:(NSNotification *)notification;

@end

@implementation JSONTableVC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryGettingJSON:) name:@"jsonError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:@"jsonSuccess" object:nil];
    
    [ZAActivityBar showWithStatus:@"Getting JSON Data" forAction:@"json"];

    _jsonModel = [JSONModel sharedInstance];
    
    _imageCache = [[NSCache alloc] init];
    
    [_jsonModel getJSONData];
    
    _retryCounter = 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebVC *nextVC = (WebVC*)segue.destinationViewController;
    
    if(_selectedIndexPath.row % 2)
    {
        nextVC.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[_jsonModel.jsonArray objectAtIndex:_selectedIndexPath.row / 2] objectForKey:@"href"]]];
    }
    else
    {
        NSString *urlString = [NSString stringWithFormat:@"http://pinterest.com/%@",
                               [[[_jsonModel.jsonArray objectAtIndex:_selectedIndexPath.row / 2] objectForKey:@"user"] objectForKey:@"username"]];
        
        nextVC.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSONTableVC

- (void)reloadData:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jsonSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jsonError" object:nil];
    
    [ZAActivityBar showSuccessWithStatus:@"Got JSON Data!" forAction:@"json"];
    
    [self.tableView reloadData];
}

- (void)retryGettingJSON:(NSNotification *)notification
{
    _retryCounter++;
    
    if(_retryCounter < 10)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (_retryCounter << 1) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_jsonModel getJSONData];
        });
    }
    else
    {
        [ZAActivityBar showErrorWithStatus:@"Error Getting JSON Data" forAction:@"json"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jsonError" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jsonSuccess" object:nil];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section > 0)
        return 1;
    
    if(_jsonModel.jsonArray)
        return _jsonModel.jsonArray.count << 1;
    
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PrettyTableViewCell *prettyCell = [tableView dequeueReusableCellWithIdentifier:indexPath.row % 2 ? @"Cell" : @"Header" ];
    
    if(!prettyCell)
    {
        prettyCell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                reuseIdentifier:indexPath.row % 2 ? @"Cell" : @"Header"];
        
        [prettyCell prepareForTableView:tableView indexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:1]];
    }
    
    prettyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row % 2)
    {
        prettyCell.indentationLevel = 1;
        prettyCell.textLabel.hidden = TRUE;
        prettyCell.detailTextLabel.hidden = TRUE;
        
        NSString *detailString = [NSString stringWithFormat:@"%@\n%@",[[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"desc"],
                                                                        [[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"attrib"]];
        
        if(![prettyCell.contentView viewWithTag:314])
        {
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 9, 257, 64)];
            
            detailLabel.tag = 314;
            detailLabel.numberOfLines = 0;
            detailLabel.text = detailString;
            detailLabel.textColor = [UIColor whiteColor];
            detailLabel.backgroundColor = [UIColor colorWithWhite:.0 alpha:.4];
            
            [prettyCell.contentView insertSubview:detailLabel aboveSubview:prettyCell.imageView];
        }
        else
        {
            UILabel *detailLabel = (UILabel*)[prettyCell.contentView viewWithTag:314];
            
            detailLabel.text = detailString;
        }
        
        NSString *pictureString = [[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"src"];
        
        if([_imageCache objectForKey:pictureString])
            prettyCell.imageView.image = [_imageCache objectForKey:pictureString];
        else
        {
            [prettyCell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pictureString]]
                                        placeholderImage:[UIImage imageNamed:@"placeholder-image"]
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     
                                                     if(![_imageCache objectForKey:pictureString])
                                                         [_imageCache setObject:[image thumbnailImage:256
                                                                                    transparentBorder:0
                                                                                         cornerRadius:0
                                                                                 interpolationQuality:kCGInterpolationDefault]
                                                                         forKey:pictureString];
                                                     
                                                     if([tableView.indexPathsForVisibleRows containsObject:indexPath])
                                                     {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             prettyCell.imageView.image = [_imageCache objectForKey:pictureString];
                                                             
                                                             [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                                              withRowAnimation:UITableViewRowAnimationFade];
                                                         });
                                                     }
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 }];
        }
    }
    else
    {
        prettyCell.textLabel.text = [[[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"user"] objectForKey:@"name"];
        prettyCell.detailTextLabel.text = [[[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"user"] objectForKey:@"username"];
        
        NSString *avatarString = [[[[_jsonModel.jsonArray objectAtIndex:indexPath.row / 2] objectForKey:@"user"] objectForKey:@"avatar"] objectForKey:@"src"];
        
        if([_imageCache objectForKey:avatarString])
            prettyCell.imageView.image = [_imageCache objectForKey:avatarString];
        else
        {
            [prettyCell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarString]]
                                        placeholderImage:[UIImage imageNamed:@"placeholder-avatar"]
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      
                                                     if(![_imageCache objectForKey:avatarString])
                                                         [_imageCache setObject:[image thumbnailImage:48
                                                                                    transparentBorder:5
                                                                                         cornerRadius:0
                                                                                 interpolationQuality:kCGInterpolationDefault]
                                                                         forKey:avatarString];
                                                      
                                                     if([tableView.indexPathsForVisibleRows containsObject:indexPath])
                                                     {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             prettyCell.imageView.image = [_imageCache objectForKey:avatarString];
                                                         
                                                             [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                                              withRowAnimation:UITableViewRowAnimationFade];
                                                         });
                                                     }
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 }];
        }
    }
    
    return prettyCell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row % 2 ? 288.f : 64.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Web" sender:self];
}

@end
