//
//  LBFadeInAnimator.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 1 Oct 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

enum TransitionType { case Presenting, Dismissing }

class LBFadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.35
    var presenting = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        toView.alpha = 0
        containerView.addSubview(toView)

        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
            if !self.presenting {
                toView.frame = containerView.bounds
                toView.setNeedsLayout()
            }
        }) { _ in
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)
        }
    }
    
}

