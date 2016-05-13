//
//  ViewController.m
//  EXFaceRecognition
//
//  Created by cqcityroot on 16/5/10.
//  Copyright © 2016年 cqmc. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "MyImageStore.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate>

@property(nonatomic,strong) CIContext *context;

@property(nonatomic,strong) CIDetector *detector;  //检测器

@property(nonatomic,strong) UIPopoverController *imagePickerPopover; //

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.imageview.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    UIImage *image = [[MyImageStore sharedStore] imageForKey:@"CYFStore"];
    self.imageview.image = image;
   
}

#pragma mark -- 懒加载
- (CIContext *)context
{
    if (_context == nil)
    {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (CIDetector *)detector
{
    if (_detector == nil)
    {
        NSDictionary *dict = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
        _detector = [CIDetector detectorOfType:CIDetectorTypeFace context:self.context options:dict];
    }
    return _detector;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Image:(id)sender {
    
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.delegate = self;
    /*
     如果这里allowsEditing设置为false，则下面的UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
     应该改为： UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
     也就是改为原图像，而不是编辑后的图像。
     */
    
    //允许编辑图片
    imagePicker.allowsEditing = YES;
    
    //如果设备支持相机，就使用拍照技术
    //否则让用户从照片库中选择照片
    //  if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    //  {
    //    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //  }
    //  else{
    //    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //  }

    /*
     这里以弹出选择框的形式让用户选择是打开照相机还是图库
     */
    //初始化提示框；
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"打开相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //创建UIPopoverController对象前先检查当前设备是不是ipad
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.imagePickerPopover.delegate = self;
            [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else{
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"我的相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
    
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //创建UIPopoverController对象前先检查当前设备是不是ipad
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.imagePickerPopover.delegate = self;
            [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else{
        
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action){
        //取消
    }]];
    
    //弹出提示框
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma PickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //通过info字典获取可选择的照片
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    //以itemkey为键，将照片存入ImageStore对象中
    [[MyImageStore sharedStore] setImage:image forKey:@"CYFStore"];
    
    //将照片放入UIImageView对象
    self.imageview.image = image;
    
    //把一张照片保存到图库中，此时无论是这招照片是照相机拍的还是本身从图库中取出的，都会保存到图库中；
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    //压缩图片，如果图片要上传到服务器或网络，则需要执行该步骤（压缩），第二个参数是压缩比例，转化为NSData类型；
    NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    
    //判断UIPopoverController对象是否还存在
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    }else{
        //关闭以模态形势显示到UIImagePickerController
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}



//人脸识别
- (IBAction)Recognise:(id)sender {
    
    //获取图片
    UIImage *image = self.imageview.image;
    //转成CIImage
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    //拿到所有的脸
    NSArray <CIFeature *> *featureArray = [self.detector featuresInImage:ciImage];

    if (featureArray.count == 0) {
        NSLog(@"未检测到人脸");
        //初始化提示框;
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到人脸" preferredStyle: UIAlertControllerStyleAlert];
        [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            //点击按钮的响应事件;
        }]];
        
        //弹出提示框;
        [self presentViewController:alert1 animated:true completion:nil];
        
    }else{
        //遍历
        for (CIFeature *feature in featureArray){
            
            //将image沿y轴对称
            CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
            //将image往上移动
            CGFloat imageH = ciImage.extent.size.height;
            transform = CGAffineTransformTranslate(transform, 0, -imageH);
            //在image上画出方框
            CGRect feaRect = feature.bounds;
            //调整后的坐标
            CGRect newFeaRect = CGRectApplyAffineTransform(feaRect, transform);
            //调整imageView的frame
            CGFloat imageViewW = self.imageview.bounds.size.width;
            CGFloat imageViewH = self.imageview.bounds.size.height;
            CGFloat imageW = ciImage.extent.size.width;
            //显示
            CGFloat scale = MIN(imageViewH / imageH, imageViewW / imageW);
            //缩放
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            
            //修正
            newFeaRect = CGRectApplyAffineTransform(newFeaRect, scaleTransform);
            newFeaRect.origin.x += (imageViewW - imageW * scale ) / 2;
            newFeaRect.origin.y += (imageViewH - imageH * scale ) / 2;
            NSLog(@"xxx:%f",newFeaRect.origin.x);
            
            //绘画
            UIView *breageView = [[UIView alloc] initWithFrame:newFeaRect];
            breageView.layer.borderColor = [UIColor redColor].CGColor;
            breageView.layer.borderWidth = 2;
            [self.imageview addSubview:breageView];
        }

    }

    
}
@end
