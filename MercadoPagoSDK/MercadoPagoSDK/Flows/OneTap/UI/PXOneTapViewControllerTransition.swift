//
//  PXOneTapViewControllerTransition.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 24/10/2019.
//

import Foundation

class PXOneTapViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {

    //make this zero for now and see if it matters when it comes time to make it interactive
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: .from) as? PXOneTapViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? NewCardAssociationViewController,
            let headerSnapshot = fromVC.headerView?.snapshotView(afterScreenUpdates: false),
            let footerSnapshot = fromVC.whiteView?.snapshotView(afterScreenUpdates: false) {

            let containerView = transitionContext.containerView

            guard var headerFrame = fromVC.headerView?.frame,
                var footerFrame = fromVC.whiteView?.frame else {
                    return
            }
            // Fix frame sizes and position
            var navigationFrame = containerView.frame
            navigationFrame.size.height -= (headerFrame.size.height + footerFrame.size.height)
            headerFrame.origin.y = navigationFrame.height
            footerFrame.origin.y = headerFrame.origin.y + headerFrame.size.height

            headerSnapshot.frame = headerFrame
            footerSnapshot.frame = footerFrame

            let navigationSnapshot = fromVC.view.resizableSnapshotView(from: navigationFrame, afterScreenUpdates: false, withCapInsets: .zero)
            // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
            let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)
            // addTopViewOverlay adds a blue placeholder view to hide topView elements
            // This view will show initially translucent and will become opaque to cover the headerView area
            addTopViewOverlay(topView: topView, backgroundColor: fromVC.view.backgroundColor)

            fromVC.view.removeFromSuperview()
            containerView.addSubview(toVC.view)
            containerView.addSubview(topView)
            containerView.addSubview(footerSnapshot)

            var pxAnimator = PXAnimator(duration: 1.25, dampingRatio: 0.8)
            pxAnimator.addAnimation(animation: {
                topView.frame = topView.frame.offsetBy(dx: 0, dy: -headerFrame.size.height)
                topView.alpha = 0
                topView.subviews.forEach({ $0.alpha = 1 })
                footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: footerSnapshot.frame.size.height)
                footerSnapshot.alpha = 0
            })

            pxAnimator.addCompletion(completion: {
                topView.removeFromSuperview()
                footerSnapshot.removeFromSuperview()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })

            pxAnimator.animate()
        } else if let fromVC = transitionContext.viewController(forKey: .from) as? NewCardAssociationViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? PXOneTapViewController,
            let toVCSnapshot = toVC.view.snapshotView(afterScreenUpdates: true),
            let headerSnapshot = toVC.headerView?.snapshotView(afterScreenUpdates: true),
            let footerSnapshot = toVC.whiteView?.snapshotView(afterScreenUpdates: true) {

            let containerView = transitionContext.containerView

            guard var headerFrame = toVC.headerView?.frame,
                var footerFrame = toVC.whiteView?.frame else {
                    return
            }
            // Fix frame sizes and position
            var navigationFrame = containerView.frame
            navigationFrame.size.height -= (headerFrame.size.height + footerFrame.size.height)
            headerFrame.origin.y = navigationFrame.height
            footerFrame.origin.y = headerFrame.origin.y + headerFrame.size.height

            headerSnapshot.frame = headerFrame
            footerSnapshot.frame = footerFrame

            let navigationSnapshot = toVCSnapshot.resizableSnapshotView(from: navigationFrame, afterScreenUpdates: true, withCapInsets: .zero)
            // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
            let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)
            // backgroundView is a white placeholder background using the entire view area
            let backgroundView = UIView(frame: containerView.frame)
            backgroundView.backgroundColor = UIColor.white
            // topViewBackground is a blue placeholder background to use as a temporary navigationbar and headerView background
            // This view will show initially offset as the navigationbar and will expand to cover the headerView area
            let topViewBackground = UIView(frame: topView.frame)
            topViewBackground.backgroundColor = toVC.view.backgroundColor
            backgroundView.addSubview(topViewBackground)
            backgroundView.addSubview(topView)
            backgroundView.addSubview(footerSnapshot)

            fromVC.view.removeFromSuperview()
            containerView.addSubview(toVC.view)
            containerView.addSubview(backgroundView)

            topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: -headerFrame.size.height)
            topView.frame = topView.frame.offsetBy(dx: 0, dy: -headerFrame.size.height)
            topView.alpha = 0
            footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: footerSnapshot.frame.size.height)
            footerSnapshot.alpha = 0

            var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
            pxAnimator.addAnimation(animation: {
                topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: headerFrame.size.height)
                footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: -footerSnapshot.frame.size.height)
                footerSnapshot.alpha = 1
            })

            pxAnimator.addCompletion(completion: {
                var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
                pxAnimator.addAnimation(animation: {
                    topView.frame = topView.frame.offsetBy(dx: 0, dy: headerFrame.size.height)
                    topView.alpha = 1
                })

                pxAnimator.addCompletion(completion: {
                    backgroundView.removeFromSuperview()

                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })

                pxAnimator.animate()
            })

            pxAnimator.animate()
        } else {
            transitionContext.completeTransition(false)
        }
    }

    private func buildTopView(containerView: UIView, navigationSnapshot: UIView?, headerSnapshot: UIView, footerSnapshot: UIView) -> UIView {
        var topFrame = containerView.frame
        topFrame.size.height -= footerSnapshot.frame.size.height
        let topView = UIView(frame: topFrame)
        if let navigationSnapshot = navigationSnapshot { topView.addSubview(navigationSnapshot) }
        topView.addSubview(headerSnapshot)
        return topView
    }

    private func addTopViewOverlay(topView: UIView, backgroundColor: UIColor?) {
        let topViewOverlay = UIView(frame: topView.frame)
        topViewOverlay.backgroundColor = backgroundColor
        topViewOverlay.alpha = 0
        topView.addSubview(topViewOverlay)
    }
}
