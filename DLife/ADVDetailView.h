//
//  ADVDetailView.h
//  BeautyLife
//
//  Created by Seven on 14-8-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertisement2.h"

@interface ADVDetailView : UIViewController<UIActionSheetDelegate>
{
    MBProgressHUD *hud;
    Advertisement *advInfo;
}

@property (weak, nonatomic) Advertisement2 *adv;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
