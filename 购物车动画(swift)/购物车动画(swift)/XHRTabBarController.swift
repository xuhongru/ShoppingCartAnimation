//
//  XHRTabBarController.swift
//  购物车动画(swift)
//
//  Created by 胥鸿儒 on 16/8/21.
//  Copyright © 2016年 xuhongru. All rights reserved.
//

import UIKit

class XHRTabBarController: UITabBarController {
    /// 购物车的中心在主窗口上的坐标
    var shoppCartCenter:CGPoint = CGPointZero
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationController = UINavigationController(rootViewController: XHRViewController())
        navigationController.tabBarItem.title = "首页"
        navigationController.tabBarItem.image = UIImage(named: "v2_home")
        navigationController.tabBarItem.selectedImage = UIImage(named: "v2_home_r")
        addChildViewController(navigationController)
        setValue(XHRTabBar(childControllCount: childViewControllers.count), forKeyPath: "tabBar")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getShoppCartCenter()
    }
    //用这个方法来计算购物车中心点的在主敞口上的坐标
    private func getShoppCartCenter()
    {
        for childView in tabBar.subviews
        {
            if childView.isKindOfClass(XHRShoppingCartButton.self)
            {
                //转换坐标系
                shoppCartCenter = tabBar.convertPoint(childView.center, toView: XHRKeyWindow)
                return
            }
        }
    }
}
class XHRTabBar: UITabBar {
    var childControllCount : Int
    init(childControllCount : Int)
    {
        self.childControllCount = childControllCount
        super.init(frame: CGRectZero)
        tintColor = UIColor.darkGrayColor()
        addSubview(shoppingCartButton)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceivedAddShoppingMessage:", name: XHRSucceedAddToShoppingMartNotification, object: nil)
    }
    func didReceivedAddShoppingMessage(object:AnyObject)
    {
        shoppingCartButton.shoppingCount++
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonH : CGFloat = self.frame.size.height;
        let buttonW : CGFloat = XHRScreenWidth / CGFloat(childControllCount + 1)
        let buttonY : CGFloat = 0
        var index:Int = 0
        //在这里重新布局tabBar上的按钮
        for childView in subviews
        {
            /// 这里描述的是多个子控制器(购物车放在第三个)的情况下,这里就写了2个做演示
            let buttonX = index >= 2 ? CGFloat(index + 1) * buttonW:CGFloat(index) * buttonW
            if childView.isKindOfClass(NSClassFromString("UITabBarButton")!)
            {
                childView.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH)
                index++
            }
            else if childView.isEqual(shoppingCartButton)
            {
                childView.frame = CGRectMake(buttonW, buttonY, buttonW, buttonH)
            }
        }
    }
    private lazy var shoppingCartButton : XHRShoppingCartButton = {
        let button  = XHRShoppingCartButton()
        button.setTitle("购物车", forState: UIControlState.Normal)
        button.setImage(UIImage(named: "shopCart"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "shopCart_r"), forState: UIControlState.Highlighted)
        button.addTarget(self, action: "actionDidClickShoppingCartButton:", forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
