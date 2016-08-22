//
//  XHRViewController.swift
//  购物车动画(swift)
//
//  Created by 胥鸿儒 on 16/8/21.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

import UIKit
import SnapKit
private let XHRCollectionViewCellID = "XHRCollectionViewCellID"
let XHRSucceedAddToShoppingMartNotification = "XHRSucceedAddToShoppingMartNotification"
/// 屏幕的bounds
let XHRScreenBounds = UIScreen.mainScreen().bounds
/// 屏幕的尺寸
let XHRScreenSize = XHRScreenBounds.size
/// 屏幕的宽度
let XHRScreenWidth = XHRScreenSize.width
/// 屏幕的高度
let XHRScreenHeight = XHRScreenSize.height
/// 主窗口
let XHRKeyWindow = UIApplication.sharedApplication().keyWindow
class XHRViewController: UIViewController {
    var animationView : UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
    }
    //初始化子控件
    private func setupChildView()
    {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(collectionView)
    }
    //这里把点击的button传过来是为了调整它的enable属性保证动画过程中按钮不可以被点击,加强用户体验
    private func startAnimation(imageView:UIImageView,button:UIButton)
    {
        //初始化旋转动画
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        //设置属性
        animation.toValue = NSNumber(double: M_PI * 11)
        animation.duration = 1
        animation.cumulative = true;
        animation.repeatCount = 0;
        //初始化抛物线动画
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        let startPoint = imageView.center
        let endPoint = (tabBarController as! XHRTabBarController).shoppCartCenter
        //抛物线的顶点,可以根据需求调整
        let controlPoint = CGPointMake(XHRScreenWidth * 0.5, startPoint.y - 100);
        //生成路径
        let path = CGPathCreateMutable();
        //描述路径
        CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y)
        CGPathAddQuadCurveToPoint(path, nil, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y)
        //设置属性
        pathAnimation.duration = 1
        pathAnimation.path = path
        //初始化动画组
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation,pathAnimation]
        animationGroup.duration = 1
        animationGroup.delegate = self
        //延时的目的是让view先做UIView动画然后再做layer动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(100000000)), dispatch_get_main_queue(), {() -> Void in
            imageView.layer.addAnimation(animationGroup, forKey: nil)
        })
        UIView.animateWithDuration(1, animations: { () -> Void in
            imageView.bounds = CGRectMake(0, 0, 10, 10)
            imageView.center = endPoint
            }) { (_) -> Void in
              button.enabled = true
        }
    }
    //懒加载控件
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: XHRScreenBounds, collectionViewLayout: XHRFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(XHRCollectionViewCell.self, forCellWithReuseIdentifier: XHRCollectionViewCellID)
        return collectionView
    }()
}
extension XHRViewController : UICollectionViewDataSource,UICollectionViewDelegate,XHRCollectionViewCellDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(XHRCollectionViewCellID, forIndexPath: indexPath) as! XHRCollectionViewCell
        cell.delegate = self
        cell.backgroundColor = UIColor.orangeColor()
        
        return cell
    }
    //这里是cell的代理方法,把需要做动画的图片和中心点以及点击的button传出来了
    func collectionViewCellDidClickAddButton(image: UIImage?, centerPoint: CGPoint, button: UIButton) {
        //先判断image是否有值
        guard let _ = image else
        {
            return
        }
        //创建动画的imageView
        let animationImageView = UIImageView(image:image)
        animationView = animationImageView
        animationImageView.center = centerPoint
        //把动画imageView添加到主窗口上
        XHRKeyWindow!.addSubview(animationImageView)
        //开始动画
        startAnimation(animationImageView,button: button)
    }
    //动画结束后调用的代理方法,将动画的imageView移除,将来还有刷新购物车数据之类的事情可以在这个方法里面做
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        //移除动画imageView
        self.animationView?.removeFromSuperview()
        //发出添加完成的通知（伪代码）
        NSNotificationCenter.defaultCenter().postNotificationName(XHRSucceedAddToShoppingMartNotification, object: "商品ID")
        
    }
}
// cell的代理方法
protocol XHRCollectionViewCellDelegate : NSObjectProtocol
{
    func collectionViewCellDidClickAddButton(image:UIImage?,centerPoint:CGPoint,button:UIButton)
}
class XHRCollectionViewCell: UICollectionViewCell
{
    weak var delegate:XHRCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(addButton)
        contentView.addSubview(imageView)
        addButton.snp_makeConstraints { (make) -> Void in
            make.trailing.bottom.equalTo(contentView).offset(-10)
        }
        imageView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(345 / 3)
            make.width.equalTo(488 / 3)
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(10)
        }
    }
    //按钮的点击方法
    func actionDidClickAddButton(sender:UIButton)
    {
        sender.enabled = false
        let centerPoint = contentView.convertPoint(imageView.center, toView: XHRKeyWindow)
        delegate?.collectionViewCellDidClickAddButton(imageView.image,centerPoint: centerPoint,button:sender)
    }
    private lazy var addButton : UIButton = {
        let button = UIButton()
        button.addTarget(self, action: "actionDidClickAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        button.setImage(UIImage(named: "v2_increase"), forState: UIControlState.Normal)
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        return button
    }()
    private lazy var imageView : UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "kenan")
        return imageView
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class XHRFlowLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        super.prepareLayout()
        minimumInteritemSpacing = 10.0
        minimumLineSpacing = 10
        itemSize = CGSizeMake((XHRScreenWidth - 10) * 0.5, 200)
    }
}