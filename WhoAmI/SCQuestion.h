//
//  SCQuestion.h
//  WhoAmI
//
//  Created by Stephen Cao on 6/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCQuestion : UIView
@property(nonatomic,copy)NSString *answer;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,strong)NSArray *options;
- (instancetype)initWithDictionary:(NSDictionary *) dict;
+ (instancetype)questionWithDictionary:(NSDictionary *) dict;
@end

NS_ASSUME_NONNULL_END
