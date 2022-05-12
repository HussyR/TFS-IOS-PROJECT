//
//  CustomTransition.swift
//  ChatAppHussyR
//
//  Created by Данил on 05.05.2022.
//

import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        print("hello")
        containerView.addSubview(toView)
        toView.alpha = 0.0
        UIView.animate(withDuration: 1,
                       animations: {
            toView.alpha = 1.0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
        
    }
}
