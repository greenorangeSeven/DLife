//
//  CommunityDetailView.m
//  NanNIng
//
//  Created by Seven on 14-9-9.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import "CommunityDetailView.h"
#import "Commercial.h"
#import "CommercialReply.h"
#import "TQImageCache.h"
#import "MWPhotoBrowser.h"
#import "CommunityReplyCell.h"

@interface CommunityDetailView ()<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,MWPhotoBrowserDelegate>
{
    NSMutableArray *replyArray;
    TQImageCache * _iconCache;
    NSArray *_photos;
}

@end

@implementation CommunityDetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"详情";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [Tool getColorForGreen];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
        
        UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 52, 27)];
        [rBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [rBtn setImage:[UIImage imageNamed:@"head_share"] forState:UIControlStateNormal];
        UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
        self.navigationItem.rightBarButtonItem = btnSearch;
    }
    return self;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(id)sender
{
    
    NSString *shareStr = [Tool flattenHTML:self.commer.content];
    NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                shareStr, @"title",
                                shareStr, @"summary",
                                thumbStr , @"thumb",
                                nil];
    [Tool shareAction:sender andShowView:self.view andContent:contentDic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    thumbStr = @"";
    if ([self.commer.thumb count] >= 1) {
        thumbStr = [self.commer.thumb objectAtIndex:0];
    }
//    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nopic4.png"]];
//    imageView.imageURL = [NSURL URLWithString:thumbStr];
//    imageView.frame = CGRectMake(0.0f, 0.0f, 208.0f, 177.0f);
//    [self.picIv addSubview:imageView];
    
    self.picIv.image = self.commer.imgData;
    
    //点击弹出事件注册
    UITapGestureRecognizer *picTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPicAction)];
	[self.picIv addGestureRecognizer:picTap];
    
    self.titleLb.text = self.commer.title;
    self.priceLb.text = [NSString stringWithFormat:@"价格:%@", self.commer.price];;
    self.summaryLb.text = self.commer.content;
    self.summaryLb.frame = CGRectMake(self.summaryLb.frame.origin.x, self.summaryLb.frame.origin.y, self.summaryLb.frame.size.width, self.commer.contentHeight);
    
    self.hitsLb.text = [NSString stringWithFormat:@"关注人数:%@人", self.commer.hits];
    self.hitsLb.frame = CGRectMake(self.hitsLb.frame.origin.x, self.summaryLb.frame.origin.y + self.summaryLb.frame.size.height, self.hitsLb.frame.size.width, self.hitsLb.frame.size.height);
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.hitsLb.frame.origin.y + self.hitsLb.frame.size.height + 5);
    
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getDetailInfo];
}

- (void)clickPicAction
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:thumbStr]]];
    
    self.photos = photos;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)getDetailInfo
{
    if ([UserModel Instance].isNetworkRunning) {
        NSString *userId = [[UserModel Instance] getUserValueForKey:@"id"];
        NSString *url = [NSString stringWithFormat:@"%@%@?APPKey=%@&userid=%@&id=%@", api_base_url, api_commercialinfo, appkey, userId, self.commer.id];
        
        [[AFOSCClient sharedClient] getPath:url parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            @try {
                [self clear];
                replyArray = [Tool readJsonStrToCommercialReply:operation.responseString];
                
                [self.tableView reloadData];
            }
            @catch (NSException *exception) {
                [NdUncaughtExceptionHandler TakeException:exception];
            }
            @finally {
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"获取出错");
            
            if ([UserModel Instance].isNetworkRunning == NO) {
                return;
            }
            if ([UserModel Instance].isNetworkRunning) {
                [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
            }
        }];
    }
}

#pragma 生命周期
- (void)viewDidUnload
{
    [self setTableView:nil];
    [replyArray removeAllObjects];
    [_imageDownloadsInProgress removeAllObjects];
    replyArray = nil;
    _iconCache = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (CommercialReply *c in replyArray) {
        c.imgData = nil;
    }
    
    [super didReceiveMemoryWarning];
}

- (void)clear
{
    [replyArray removeAllObjects];
    [_imageDownloadsInProgress removeAllObjects];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma 下载图片
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [_imageDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}

- (void)appImageDidLoad:(NSString *)index
{
    IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:index];
    if (iconDownloader)
    {
        int _index = [index intValue];
        if (_index >= [replyArray count])
        {
            return;
        }
        CommercialReply *c = [replyArray objectAtIndex:[index intValue]];
        if (c) {
            c.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(c.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:c.avatar]];
            [self.tableView reloadData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return replyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommercialReply *reply = [replyArray objectAtIndex:[indexPath row]];
    int height = 82 + reply.contentHeight - 21;
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CommunityReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:CommunityReplyCellIdentifier];
    if (!cell)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CommunityReplyCell" owner:self options:nil];
        for (NSObject *o in objects)
        {
            if ([o isKindOfClass:[CommunityReplyCell class]])
            {
                cell = (CommunityReplyCell *)o;
                break;
            }
        }
    }
    CommercialReply *bbs = [replyArray objectAtIndex:[indexPath row]];
    //内容
    cell.contentLb.text = bbs.reply_content;
    cell.nickNameLb.text = bbs.nickname;
    cell.timeLb.text = bbs.timeStr;
    CGRect contentLb = cell.contentLb.frame;
    cell.contentLb.frame = CGRectMake(contentLb.origin.x, contentLb.origin.y, contentLb.size.width, bbs.contentHeight);
    
    //头像
    if (bbs.imgData) {
        cell.faceIV.image = bbs.imgData;
    }
    else
    {
        if ([bbs.avatar isEqualToString:@""]) {
            bbs.imgData = [UIImage imageNamed:@"userface"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:bbs.avatar]];
            if (imageData)
            {
                bbs.imgData = [UIImage imageWithData:imageData];
                cell.faceIV.image = bbs.imgData;
            }
            else
            {
                IconDownloader *downloader = [_imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    record.url = bbs.avatar;
                    [self startIconDownload:record forIndexPath:indexPath];
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)replyBtn:(id)sender {
    NSString *contentStr = self.replyTV.text;
    if (contentStr == nil || [contentStr length] == 0)
    {
        [Tool showCustomHUD:@"请填写回复内容" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    [self.replyTV resignFirstResponder];
    UserModel *usermodel = [UserModel Instance];
    NSString *updateUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_replycommercial];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:updateUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:appkey forKey:@"APPKey"];
    [request setPostValue:[usermodel getUserValueForKey:@"id"] forKey:@"userid"];
    [request setPostValue:self.commer.id forKey:@"id"];
    [request setPostValue:contentStr forKey:@"reply_content"];
    request.delegate = self;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)requestSubmit:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!json) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:request.responseString
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    User *user = [Tool readJsonStrToUser:request.responseString];
    int errorCode = [user.status intValue];
    NSString *errorMessage = user.info;
    switch (errorCode) {
        case 1:
        {
            [Tool showCustomHUD:@"回复成功" andView:self.view  andImage:@"37x-Checkmark.png" andAfterDelay:3];
            CommercialReply *reply = [[CommercialReply alloc] init];

            NSString *rname = @"匿名用户";
            UserModel *usermodel = [UserModel Instance];
            if ([[usermodel getUserValueForKey:@"nickname"] isEqualToString:@""] == NO)
            {
                rname = [NSString stringWithFormat:@"%@", [usermodel getUserValueForKey:@"nickname"]];
            }
            else if ([[usermodel getUserValueForKey:@"name"] isEqualToString:@""] == NO)
            {
                rname = [NSString stringWithFormat:@"%@", [usermodel getUserValueForKey:@"name"]];
            }
            reply.nickname = rname;
            reply.timeStr = @"刚刚";
            NSString *contentStr = self.replyTV.text;
            int replyHeight = [Tool getTextHeight:300 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:12] andText:contentStr];
            reply.reply_content = contentStr;
            reply.avatar = [usermodel getUserValueForKey:@"avatar"];
            reply.contentHeight = replyHeight;
            [replyArray insertObject:reply atIndex:0];
            [self.tableView reloadData];
            
            self.replyTV.text = @"";
            
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:errorMessage andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:3];
        }
            break;
    }
}
@end
