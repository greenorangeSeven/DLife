//
//  ReSetPwdView.h
//  BeautyLife
//
//  Created by Seven on 14-9-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReSetPwdView : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mobileTf;
@property (weak, nonatomic) IBOutlet UITextField *pwdTf;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgainTf;
@property (weak, nonatomic) IBOutlet UITextField *securityCodeTf;
@property (weak, nonatomic) IBOutlet UIButton *securityCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

- (IBAction)sendSecurityCodeAction:(id)sender;
- (IBAction)resetAction:(id)sender;

@end
