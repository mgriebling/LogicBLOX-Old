//
//  LBTransitionManager.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 1 Oct 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let container = transitionContext.containerView
        container.addSubview(toView)
        container.addSubview(fromView)
        UIView.animate(withDuration: duration, animations: {
            fromView.alpha = 0
            toView.alpha = 1
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
}

extension LBTransitionManager : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}
