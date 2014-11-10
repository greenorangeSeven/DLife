//
//  ReSetPwdView.m
//  BeautyLife
//
//  Created by Seven on 14-9-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ReSetPwdView.h"

@interface ReSetPwdView ()

@end

@implementation ReSetPwdView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"重置密码";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [Tool getColorForGreen];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
    }
    return self;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.securityCodeTf.delegate = self;
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(int)getRandomNumber:(int)start to:(int)end
{
    return (int)(start + (arc4random() % (end - start + 1)));
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *mobileStr = self.mobileTf.text;
    NSString *SMSStr = (NSString *)[[EGOCache currentCache] objectForKey:ReSetSecurityCode];
    NSString *randomStr = textField.text;
    if ([[NSString stringWithFormat:@"%@%@", randomStr, mobileStr] isEqualToString:SMSStr] == NO) {
        [Tool showCustomHUD:@"验证码错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
    }
    else
    {
        [Tool showCustomHUD:@"验证码成功" andView:self.view  andImage:@"37x-Checkmark.png" andAfterDelay:2];
        [[EGOCache currentCache] removeCacheForKey:ReSetSecurityCode];
        self.pwdTf.enabled = YES;
        self.pwdAgainTf.enabled = YES;
        self.resetBtn.enabled = YES;
        self.mobileTf.enabled = NO;
        self.securityCodeTf.enabled = NO;
    }
}

- (IBAction)sendSecurityCodeAction:(id)sender
{
//    NSString *mobileStr = self.mobileTf.text;
//    if (![mobileStr isValidPhoneNum]) {
//        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
//        return;
//    }
//    [self.mobileTf resignFirstResponder];
//    NSString *random =  [NSString stringWithFormat:@"%d" ,[self getRandomNumber:100000 to:999999]];
//    NSString *securityCode = [NSString stringWithFormat:@"%@%@" ,random, mobileStr];
//    [[EGOCache currentCache] setObject:securityCode forKey:ReSetSecurityCode withTimeoutInterval:60 * 10];
//    NSString *regUrl = SMSURL;
//    
//    NSString *content = [NSString stringWithFormat:@"尊敬的客户：欢迎使用D.生活，您的重置密码验证码是%@，10分钟内有效。如短信不想接收，可退订回复TD【广西微动力】", random];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUrl]];
//    [request setUseCookiePersistence:NO];
//    [request setPostValue:SMSCorpID forKey:@"CorpID"];
//    [request setPostValue:SMSPWD forKey:@"Pwd"];
//    [request setPostValue:mobileStr forKey:@"Mobile"];
//    [request setPostValue:content forKey:@"Content"];
//    [request setDelegate:self];
//    [request setDidFailSelector:@selector(requestFailed:)];
//    [request setDidFinishSelector:@selector(requestSend:)];
//    [request startAsynchronous];
//    [self.securityCodeBtn setEnabled:NO];
//    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [Tool showHUD:@"发送中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}

- (void)requestSend:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSLog([NSString stringWithFormat:@"|%@|", request.responseString]);
    
    if ([request.responseString isEqualToString:@"0"]) {
        [Tool showCustomHUD:@"验证码发送成功" andView:self.view  andImage:@"" andAfterDelay:1];
    }
    else
    {
        [Tool showCustomHUD:@"验证码发送失败，请重试" andView:self.view  andImage:@"" andAfterDelay:1];
        [self.securityCodeBtn setEnabled:YES];
    }
}

- (IBAction)resetAction:(id)sender
{
    NSString *pwdStr = self.pwdTf.text;
    NSString *pwdAgainStr = self.pwdAgainTf.text;
    if (pwdStr == nil || [pwdStr length] == 0) {
        [Tool showCustomHUD:@"请输入新密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![pwdStr isEqualToString:pwdAgainStr]) {
        [Tool showCustomHUD:@"密码确认不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        self.pwdAgainTf.text = @"";
        return;
    }
    [self.pwdTf resignFirstResponder];
    [self.pwdAgainTf resignFirstResponder];
    self.resetBtn.enabled = NO;
    NSString *changeUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_resetpwd];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:changeUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:appkey forKey:@"APPKey"];
    [request setPostValue:[[UserModel Instance] getUserValueForKey:@"tel"] forKey:@"userid"];
    [request setPostValue:pwdStr forKey:@"newpwd"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestChange:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交" andView:self.view andHUD:request.hud];
}

- (void)requestChange:(ASIHTTPRequest *)request
{
    if (request.hud) {
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
            self.pwdTf.text = @"";
            self.pwdAgainTf.text = @"";
            [Tool showCustomHUD:errorMessage andView:self.view  andImage:@"37x-Checkmark.png" andAfterDelay:3];
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:errorMessage andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:3];
            self.resetBtn.enabled = YES;
        }
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
