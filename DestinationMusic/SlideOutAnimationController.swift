//
//  SlideOutAnimationController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/7.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    //transitionDuration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from){
            let containerView = transitionContext.containerView
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:{
                fromView.center.y -= containerView.bounds.height
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion:{ finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
