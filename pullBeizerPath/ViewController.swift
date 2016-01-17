    //
    //  ViewController.swift
    //  pullBeizerPath
    //
    //  Created by admin on 16/1/16.
    //  Copyright © 2016年 admin. All rights reserved.
    //

    import UIKit

    private let minimalHeight:CGFloat = 50.0
    private let shapeLayer = CAShapeLayer()
    private let maxWaveHeight:CGFloat = 150.0//设置波峰的最高点

    private let l3ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l1ControlPointView = UIView()
    private let cControlPointView =  UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()

    private var displayLink:CADisplayLink!
    private var animating = false {
        didSet{
            displayLink.paused = !animating
        }
    }

    extension UIView {
        func dg_center(usePresentationLayerIfPossible:Bool) ->CGPoint {
            if usePresentationLayerIfPossible,let presentationLayer = layer.presentationLayer() as? CALayer {
                return presentationLayer.position
            }
            return center
        }
    }


    class ViewController: UIViewController  {

        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        override func loadView() {
            super.loadView()
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: minimalHeight)
            
            shapeLayer.backgroundColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0).CGColor
            shapeLayer.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
            view.layer.addSublayer(shapeLayer)
            
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureDidMove:"))
            
            l3ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            l2ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            l1ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            cControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            r1ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            r2ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            r3ControlPointView.frame = CGRect(x: 0.0, y: 0.0, width: 3.0, height: 3.0)
            
            l3ControlPointView.backgroundColor = .redColor()
            l2ControlPointView.backgroundColor = .yellowColor()
            l1ControlPointView.backgroundColor = .blueColor()
            cControlPointView.backgroundColor = .cyanColor()
            r1ControlPointView.backgroundColor = .greenColor()
            r2ControlPointView.backgroundColor = .blackColor()
            r3ControlPointView.backgroundColor = .orangeColor()
            
            view.addSubview(l3ControlPointView)
            view.addSubview(l2ControlPointView)
            view.addSubview(l1ControlPointView)
            view.addSubview(cControlPointView)
            view.addSubview(r1ControlPointView)
            view.addSubview(r2ControlPointView)  
            view.addSubview(r3ControlPointView)
            
            layoutControlPoints(baseHeight: minimalHeight, waveHeight: 0.0, locationX: view.bounds.size.width/2)
            updateShapeLayer()
            
            shapeLayer.backgroundColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0).CGColor
            shapeLayer.fillColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0).CGColor
            
            displayLink = CADisplayLink(target: self, selector: Selector("updateShapeLayer"))
            displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            displayLink.paused = true

        }
        
        private func currentPath() -> CGPath {
            let width =  view.bounds.size.width
            let bezierPath = UIBezierPath()
            
            bezierPath.moveToPoint(CGPoint(x: 0.0, y: 0.0))
            bezierPath.addLineToPoint(CGPoint(x: 0.0, y: l3ControlPointView.dg_center(animating).y))
            
            bezierPath.addCurveToPoint(l1ControlPointView.dg_center(animating), controlPoint1: l3ControlPointView.dg_center(animating), controlPoint2: l2ControlPointView.dg_center(animating))//添加三阶曲线
            
            bezierPath.addCurveToPoint(r1ControlPointView.dg_center(animating), controlPoint1: cControlPointView.dg_center(animating), controlPoint2: r1ControlPointView.dg_center(animating))
            
            bezierPath.addCurveToPoint(r3ControlPointView.dg_center(animating), controlPoint1: r1ControlPointView.dg_center(animating), controlPoint2: r2ControlPointView.dg_center(animating))
            
            bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
            
            bezierPath.closePath()
            
            return bezierPath.CGPath
        }
        //将该方法添加到定时器中，让
        func updateShapeLayer() {
            shapeLayer.path = currentPath()
        }
        //下面的参数都是通过paintCode来获得最佳点的参数得出
        //当前可以得出：通过多次更改高度，并描绘符合逻辑的曲线，然后从曲线上面得出对应的点。得到多组数据来得到各组的比例参数
        private func layoutControlPoints(baseHeight baseHeight: CGFloat, waveHeight: CGFloat, locationX: CGFloat) {
            let width = view.bounds.width
            
            let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
            let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
            
            let leftPartWidth = locationX - minLeftX
            let rightPartWidth = maxRightX - locationX
            
            l3ControlPointView.center = CGPoint(x: minLeftX, y: baseHeight)
            l2ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
            l1ControlPointView.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
            cControlPointView.center = CGPoint(x: locationX , y: baseHeight + waveHeight * 1.36)//顶点永远跟随触摸点
            r1ControlPointView.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
            r2ControlPointView.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
            r3ControlPointView.center = CGPoint(x: maxRightX, y: baseHeight)
        }
        //这里对7个点添加弹动动画，而前面我们已经使用了DispalyLink执行的shaperLayer的更新，因此
        //shaperLayer的形状会根据7个的位置变化而变化
        func panGestureDidMove(gesture:UIPanGestureRecognizer){
            if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
                let centerY = minimalHeight
                animating = true
                view.userInteractionEnabled = !animating
                UIView.animateWithDuration(0.9, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                    l3ControlPointView.center.y = centerY
                    l2ControlPointView.center.y = centerY
                    l1ControlPointView.center.y = centerY
                    cControlPointView.center.y = centerY
                    r1ControlPointView.center.y = centerY
                    r2ControlPointView.center.y = centerY
                    r3ControlPointView.center.y = centerY
                    }, completion: { _ in
                        animating = false
                        self.view.userInteractionEnabled = !animating
                })
                
            }else{
                let additionalHeight = max(gesture.translationInView(view).y, 0)
                let waveHeight = min(additionalHeight * 0.6,maxWaveHeight)
                let baseHeight = minimalHeight + additionalHeight - waveHeight
                
                let locationX = gesture.locationInView(gesture.view).x
                
                layoutControlPoints(baseHeight: baseHeight, waveHeight: waveHeight, locationX: locationX)
                updateShapeLayer()
                
            }
        }
        
        override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return UIStatusBarStyle.LightContent
        }
    }


