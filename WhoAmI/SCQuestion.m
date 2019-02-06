//
//  SCQuestion.m
//  WhoAmI
//
//  Created by Stephen Cao on 6/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import "SCQuestion.h"
@interface SCQuestion()
@end
@implementation SCQuestion
- (instancetype)initWithDictionary:(NSDictionary *) dict{
    self = [super init];
    if (self) {
        self.answer = dict[@"answer"];
        self.icon = dict[@"icon"];
        self.title = dict[@"title"];
        self.options = dict[@"options"];
    }
    return self;
}
+ (instancetype)questionWithDictionary:(NSDictionary *) dict{
    return [[self alloc]initWithDictionary:dict];
}
@end
