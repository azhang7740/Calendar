//
//  RightToLeftTransition.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation

class RightToLeftTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        container.addSubview(toView)
        toView.frame.origin = CGPoint(x: toView.frame.width, y: 0)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
