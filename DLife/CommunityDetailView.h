//
//  CommunityDetailView.h
//  NanNIng
//
//  Created by Seven on 14-9-9.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommunityDetailView : UIViewController
{
    NSString *thumbStr;
}

@property (nonatomic, retain) NSArray *photos;
@property (weak, nonatomic) Commercial *commer;

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIImageView *picIv;
@property (weak, nonatomic) IBOutlet UILabel *summaryLb;
@property (weak, nonatomic) IBOutlet UILabel *hitsLb;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (weak, nonatomic) IBOutlet UITextField *replyTV;
- (IBAction)replyBtn:(id)sender;

@end
