//
//  MyImageStore.m
//  EXFaceRecognition
//
//  Created by cqcityroot on 16/5/11.
//  Copyright © 2016年 cqmc. All rights reserved.
//

#import "MyImageStore.h"

@interface MyImageStore()

@property (nonatomic,strong) NSMutableDictionary *dic;

-(NSString *)imagePathForKey:(NSString *)key;

@end

@implementation MyImageStore

+ (instancetype)sharedStore{
    
    static MyImageStore *instance = nil;
    //确保多线程中只创建一次对象,线程安全的单例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    
    return instance;
}


-(instancetype)initPrivate{

    self = [super init];
    if(self){
    
        _dic = [[NSMutableDictionary alloc] init];
        //注册为低内存通知的观察者
        NSNotificationCenter *notice = [NSNotificationCenter defaultCenter];
        [notice addObserver:self selector:@selector(clearCaches) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

-(void)setImage:(UIImage *)image forKey:(NSString *)key{

    [self.dic setObject:image forKey:key];
    //获取保存图片等全路径
    NSString *path = [self imagePathForKey:key];
    //从图片提取JEPG格式的数据，第二个参数为图片等压缩参数
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    //以png格式提取图片数据
    //NSdata *data = UIImagePNGRepresentation(image,0.5);
    
    //将图片数据写入文件
    [data writeToFile:path atomically:YES];
    
}

-(UIImage *)imageForKey:(NSString *)Key{

    UIImage *image = [self.dic objectForKey:Key];
    if (!image) {
        NSString *path = [self imagePathForKey:Key];
        image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            [self.dic setObject:image forKey:Key];
        }else{
            NSLog(@"Error:unable to find %@",[self imagePathForKey:Key]);
        }
    }
    
    return image;
}

-(NSString *)imagePathForKey:(NSString *)key{

    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingString:key];
}


-(void)clearCaches:(NSNotification *)n{

    NSLog(@"Flushing %ld images out of the cache", (unsigned long)[self.dic count]);
    [self.dic removeAllObjects];

}


@end
