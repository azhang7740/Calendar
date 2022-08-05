//
//  LeftToRightTransition.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/2/22.
//

import Foundation

class LeftToRightTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!

        container.addSubview(fromView)
        fromView.frame.origin = .zero

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0)
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}
