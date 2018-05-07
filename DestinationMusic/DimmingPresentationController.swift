//
//  DimmingPresentationController.swift
//  DestinationMusic
//
//  Created by locklight on 2018/5/7.
//  Copyright © 2018年 locklight. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
    }

    override var shouldRemovePresentersView: Bool{
        return false
    }
}
