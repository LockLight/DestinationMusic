//
//  FadeOutAnimationController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/8.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView.alpha = 0
            }) { (finished) in
                transitionContext.completeTransition(finished)
            }
        }
    }
}
