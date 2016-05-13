//
//  ViewController.h
//  EXFaceRecognition
//
//  Created by cqcityroot on 16/5/10.
//  Copyright © 2016年 cqmc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftbutton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightbutton;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

- (IBAction)Image:(id)sender;
- (IBAction)Recognise:(id)sender;

@end

