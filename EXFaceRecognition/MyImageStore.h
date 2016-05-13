//
//  MyImageStore.h
//  EXFaceRecognition
//
//  Created by cqcityroot on 16/5/11.
//  Copyright © 2016年 cqmc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MyImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image  forKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)Key;

@end
