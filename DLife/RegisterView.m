//
//  RegisterView.m
//  BeautyLife
//
//  Created by Seven on 14-7-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RegisterView.h"
#import "EGOCache.h"

@interface RegisterView ()

@end

@implementation RegisterView
@synthesize scrollView;
@synthesize mobileTf;
@synthesize pwdTf;
@synthesize pwdAgainTf;
@synthesize securityCodeTf;
@synthesize securityCodeBtn;
@synthesize registerBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"注册";
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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)getRandomNumber:(int)start to:(int)end
{
    return (int)(start + (arc4random() % (end - start + 1)));
}

- (IBAction)sendSecurityCodeAction:(id)sender {
    
//    NSString *mobileStr = self.mobileTf.text;
//    if (![mobileStr isValidPhoneNum]) {
//        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
//        return;
//    }
//    NSString *random =  [NSString stringWithFormat:@"%d" ,[self getRandomNumber:100000 to:999999]];
//    NSString *securityCode = [NSString stringWithFormat:@"%@%@" ,random, mobileStr];
//    [[EGOCache currentCache] setObject:securityCode forKey:SecurityCode withTimeoutInterval:60 * 10];
//    NSString *regUrl = SMSURL;
//    NSString *content = [NSString stringWithFormat:@"尊敬的客户：欢迎使用D.生活，您的注册验证码是%@，10分钟内有效。如短信不想接收，可退订回复TD【广西微动力】", random];
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
//    [securityCodeBtn setEnabled:NO];
//    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [Tool showHUD:@"发送中..." andView:self.view andHUD:request.hud];
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
        [securityCodeBtn setEnabled:YES];
    }
}

- (IBAction)registerAction:(id)sender {
    NSString *mobileStr = self.mobileTf.text;
    NSString *pwdStr = self.pwdTf.text;
    NSString *pwdAgainStr = self.pwdAgainTf.text;
    NSString *randomStr = self.securityCodeTf.text;
//    NSString *SMSStr = (NSString *)[[EGOCache currentCache] objectForKey:SecurityCode];
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (pwdStr == nil || [pwdStr length] == 0) {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![pwdStr isEqualToString:pwdAgainStr]) {
        [Tool showCustomHUD:@"密码确认不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        self.pwdAgainTf.text = @"";
        return;
    }
//    if ([[NSString stringWithFormat:@"%@%@", randomStr, mobileStr] isEqualToString:SMSStr] == NO) {
//        [Tool showCustomHUD:@"验证码错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
//        return;
//    }
    self.registerBtn.enabled = NO;
    NSString *regUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_register];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:appkey forKey:@"APPKey"];
    [request setPostValue:mobileStr forKey:@"tel"];
    [request setPostValue:pwdStr forKey:@"pwd"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegister:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在注册" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestRegister:(ASIHTTPRequest *)request
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
//            [[UserModel Instance] saveIsLogin:YES];
//            [[EGOCache currentCache] removeCacheForKey:SecurityCode];
            [[UserModel Instance] saveAccount:self.mobileTf.text andPwd:self.pwdTf.text];
            [[UserModel Instance] saveValue:self.mobileTf.text ForKey:@"tel"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注册提醒"
                                                         message:@"注册成功，请登录并完善您的资料，以便缴费和享受更多服务。"
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
            [av show];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:errorMessage andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:3];
            self.registerBtn.enabled = YES;
        }
            break;
    }
}

@end
