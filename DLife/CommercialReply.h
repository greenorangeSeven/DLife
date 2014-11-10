//
//  CommercialReply.h
//  QuJing
//
//  Created by Seven on 14-9-25.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommercialReply : NSObject

@property (nonatomic, retain) NSString *reply_id;
@property (nonatomic, retain) NSString *info_id;
@property (nonatomic, retain) NSString *reply_content;
@property (nonatomic, retain) NSString *reply_time;
@property (nonatomic, retain) NSString *customer_id;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *avatar;

@property (nonatomic, retain) NSString *timeStr;
@property int contentHeight;
@property (retain,nonatomic) UIImage * imgData;

@end
