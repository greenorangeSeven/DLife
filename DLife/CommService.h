//
//  CommService.h
//  QuJing
//
//  Created by mac on 14-9-24.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

//社区服务模型
@interface CommService : NSObject
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *thumb;
@property (nonatomic,copy) NSString *summary;
@property (retain,nonatomic) UIImage * imgData;
@end
