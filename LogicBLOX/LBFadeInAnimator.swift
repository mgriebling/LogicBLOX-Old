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
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

//        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        toView.alpha = 0
        
//        if presenting {
        containerView.addSubview(toView)
//        } else {
//            containerView.insertSubview(toView, belowSubview: fromView)
//        }

        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
//            print("toView frame = \(toView.frame), container bounds = \(containerView.bounds)")
            if !self.presenting {
//                print("Updating layout...")
                toView.frame = containerView.bounds
                toView.setNeedsLayout()
            }
        }) { _ in
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)

        }
    }
    
}

