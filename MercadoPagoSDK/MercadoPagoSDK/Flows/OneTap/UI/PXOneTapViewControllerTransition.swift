//
//  PXOneTapViewControllerTransition.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 24/10/2019.
//

import Foundation
import MLCardForm

class PXOneTapViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    //make this zero for now and see if it matters when it comes time to make it interactive
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        if fromVC is PXOneTapViewController { // Animations from OneTap
            if toVC is MLCardFormViewController {
                animateFromOneTapToCardForm(transitionContext: transitionContext)
            } else if toVC is PXSecurityCodeViewController {
                animateFromOneTapToSecurityCode(transitionContext: transitionContext)
            }
        } else if toVC is PXOneTapViewController { // Animations to OneTap
            if fromVC is MLCardFormViewController {
                animateFromCardFormToOneTap(transitionContext: transitionContext)
            } else if fromVC is PXSecurityCodeViewController {
                animateFromSecurityCodeToOneTap(transitionContext: transitionContext)
            }
        } else {
            transitionContext.completeTransition(false)
        }
    }

    private func animateFromOneTapToSecurityCode(transitionContext: UIViewControllerContextTransitioning) {
        guard let oneTapVC = transitionContext.viewController(forKey: .from) as? PXOneTapViewController,
            let securityCodeVC = transitionContext.viewController(forKey: .to) as? PXSecurityCodeViewController,
            let headerSnapshot = oneTapVC.headerView?.snapshotView(afterScreenUpdates: false),
            let footerSnapshot = oneTapVC.whiteView?.snapshotView(afterScreenUpdates: false),
            let cell = oneTapVC.slider.getSelectedCell(),
            let cardSnapshot = cell.containerView.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(false)
                return
        }

        let containerView = transitionContext.containerView

        let fixedFrames = buildFrames(oneTapVC: oneTapVC, containerView: containerView)
        headerSnapshot.frame = fixedFrames.headerFrame
        footerSnapshot.frame = fixedFrames.footerFrame

        let navigationSnapshot = oneTapVC.view.resizableSnapshotView(from: fixedFrames.navigationFrame, afterScreenUpdates: false, withCapInsets: .zero)
        // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
        let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)

        topView.addSubview(buildTopViewOverlayColor(color: oneTapVC.view.backgroundColor, topView: topView))
        containerView.addSubview(securityCodeVC.view)

        securityCodeVC.view.frame = transitionContext.finalFrame(for: securityCodeVC)
        containerView.addSubview(topView)
        if securityCodeVC.viewModel.shouldShowCard() { containerView.addSubview(cardSnapshot) }

        let startOrigin = cell.superview?.convert(cell.frame.origin, to: nil) ?? CGPoint.zero
        cardSnapshot.frame.origin = startOrigin

        var animator = PXAnimator(duration: 0.8, dampingRatio: 1)
        animator.addAnimation(animation: {
            topView.frame = topView.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
            cardSnapshot.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            cardSnapshot.frame.origin.x = (footerSnapshot.frame.size.width - cardSnapshot.frame.size.width) / 2
            cardSnapshot.frame.origin.y = securityCodeVC.getStatusAndNavBarHeight() + securityCodeVC.titleLabel.intrinsicContentSize.height + PXLayout.L_MARGIN + PXLayout.XXXS_MARGIN
        })

        animator.addCompletion(completion: {
            oneTapVC.view.removeFromSuperview()
            topView.removeFromSuperview()
            cardSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        animator.animate()
    }

    private func animateFromOneTapToCardForm(transitionContext: UIViewControllerContextTransitioning) {
        guard let oneTapVC = transitionContext.viewController(forKey: .from) as? PXOneTapViewController,
            let addCardVC = transitionContext.viewController(forKey: .to) as? MLCardFormViewController,
            let headerSnapshot = oneTapVC.headerView?.snapshotView(afterScreenUpdates: false),
            let footerSnapshot = oneTapVC.whiteView?.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
        }

        let containerView = transitionContext.containerView
        let fixedFrames = buildFrames(oneTapVC: oneTapVC, containerView: containerView)

        headerSnapshot.frame = fixedFrames.headerFrame
        footerSnapshot.frame = fixedFrames.footerFrame

        let navigationSnapshot = oneTapVC.view.resizableSnapshotView(from: fixedFrames.navigationFrame, afterScreenUpdates: false, withCapInsets: .zero)
        // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
        let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)
        // addTopViewOverlay adds a blue placeholder view to hide topView elements
        // This view will show initially translucent and will become opaque to cover the headerView area
        addTopViewOverlay(topView: topView, backgroundColor: oneTapVC.view.backgroundColor)

        oneTapVC.view.removeFromSuperview()
        containerView.addSubview(addCardVC.view)
        containerView.addSubview(topView)
        containerView.addSubview(footerSnapshot)

        topView.addSubview(buildTopViewOverlayColor(color: oneTapVC.view.backgroundColor, topView: topView))

        var pxAnimator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
        pxAnimator.addAnimation(animation: {
            topView.frame = topView.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
            footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: footerSnapshot.frame.size.height)
        })

        pxAnimator.addCompletion(completion: {
            topView.removeFromSuperview()
            footerSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

        pxAnimator.animate()
    }

    private func animateFromCardFormToOneTap(transitionContext: UIViewControllerContextTransitioning) {
        guard let addCardVC = transitionContext.viewController(forKey: .from) as? MLCardFormViewController,
            let oneTapVC = transitionContext.viewController(forKey: .to) as? PXOneTapViewController,
            let toVCSnapshot = oneTapVC.view.snapshotView(afterScreenUpdates: true),
            let headerSnapshot = oneTapVC.headerView?.snapshotView(afterScreenUpdates: true),
            let footerSnapshot = oneTapVC.whiteView?.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(false)
                return
        }

        addCardVC.title = nil

        let containerView = transitionContext.containerView
        let fixedFrames = buildFrames(oneTapVC: oneTapVC, containerView: containerView)

        headerSnapshot.frame = fixedFrames.headerFrame
        footerSnapshot.frame = fixedFrames.footerFrame

        let navigationSnapshot = toVCSnapshot.resizableSnapshotView(from: fixedFrames.navigationFrame, afterScreenUpdates: true, withCapInsets: .zero)
        // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
        let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)
        // backgroundView is a white placeholder background using the entire view area
        let backgroundView = UIView(frame: containerView.frame)
        backgroundView.backgroundColor = UIColor.white
        // topViewBackground is a blue placeholder background to use as a temporary navigationbar and headerView background
        // This view will show initially offset as the navigationbar and will expand to cover the headerView area
        let topViewBackground = UIView(frame: topView.frame)
        topViewBackground.backgroundColor = oneTapVC.view.backgroundColor
        backgroundView.addSubview(topViewBackground)
        backgroundView.addSubview(topView)
        backgroundView.addSubview(footerSnapshot)

        addCardVC.view.removeFromSuperview()
        containerView.addSubview(oneTapVC.view)
        containerView.addSubview(backgroundView)

        topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
        topView.frame = topView.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
        topView.alpha = 0
        footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: footerSnapshot.frame.size.height)
        footerSnapshot.alpha = 0

        var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
        pxAnimator.addAnimation(animation: {
            topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: fixedFrames.headerFrame.size.height)
            footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: -footerSnapshot.frame.size.height)
            footerSnapshot.alpha = 1
        })

        pxAnimator.addCompletion(completion: {
            var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
            pxAnimator.addAnimation(animation: {
                topView.frame = topView.frame.offsetBy(dx: 0, dy: fixedFrames.headerFrame.size.height)
                topView.alpha = 1
            })

            pxAnimator.addCompletion(completion: {
                backgroundView.removeFromSuperview()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })

            pxAnimator.animate()
        })

        pxAnimator.animate()
    }

    private func animateFromSecurityCodeToOneTap(transitionContext: UIViewControllerContextTransitioning) {
        guard let securityCodeVC = transitionContext.viewController(forKey: .from) as? PXSecurityCodeViewController,
            let oneTapVC = transitionContext.viewController(forKey: .to) as? PXOneTapViewController,
            let toVCSnapshot = oneTapVC.view.snapshotView(afterScreenUpdates: true),
            let headerSnapshot = oneTapVC.headerView?.snapshotView(afterScreenUpdates: true),
            let footerSnapshot = oneTapVC.whiteView?.snapshotView(afterScreenUpdates: true),
            let cell = oneTapVC.slider.getSelectedCell(),
            let cardSnapshot = cell.containerView.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(false)
                return
        }

        let containerView = transitionContext.containerView
        let fixedFrames = buildFrames(oneTapVC: oneTapVC, containerView: containerView)

        headerSnapshot.frame = fixedFrames.headerFrame
        footerSnapshot.frame = fixedFrames.footerFrame

        let navigationSnapshot = toVCSnapshot.resizableSnapshotView(from: fixedFrames.navigationFrame, afterScreenUpdates: true, withCapInsets: .zero)
        // topView is a view containing a snapshot of the navigationbar and a snapshot of the headerView
        let topView = buildTopView(containerView: containerView, navigationSnapshot: navigationSnapshot, headerSnapshot: headerSnapshot, footerSnapshot: footerSnapshot)
        // backgroundView is a white placeholder background using the entire view area
        let backgroundView = UIView(frame: containerView.frame)
        backgroundView.backgroundColor = UIColor.white
        // topViewBackground is a blue placeholder background to use as a temporary navigationbar and headerView background
        // This view will show initially offset as the navigationbar and will expand to cover the headerView area
        let topViewBackground = UIView(frame: topView.frame)
        topViewBackground.backgroundColor = oneTapVC.view.backgroundColor
        backgroundView.addSubview(topViewBackground)
        backgroundView.addSubview(topView)
        backgroundView.addSubview(footerSnapshot)
        if securityCodeVC.viewModel.shouldShowCard() {
            backgroundView.addSubview(cardSnapshot)
            let cardCellFrame = cell.containerView.frame
            let cardCellOriginInWhiteView = cell.containerView.superview?.convert(cardCellFrame.origin, to: oneTapVC.whiteView) ?? CGPoint.zero
            // hideCardView is an empty view to hide the card in the whiteView, while the animated card comes down
            let offset = CGFloat(4)
            let hideCardView = UIView(frame: CGRect(x: cardCellOriginInWhiteView.x - offset,
                                                    y: cardCellOriginInWhiteView.y - offset,
                                                    width: cardCellFrame.width + (offset * 2),
                                                    height: cardCellFrame.height + (offset * 2)))
            hideCardView.backgroundColor = oneTapVC.whiteView?.backgroundColor
            footerSnapshot.addSubview(hideCardView)
        }

        cardSnapshot.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
        let startOrigin = securityCodeVC.cardContainerView.superview?.convert(securityCodeVC.cardContainerView.frame.origin, to: nil) ?? CGPoint.zero
        cardSnapshot.frame.origin = startOrigin
        var endOrigin = cell.superview?.convert(cell.frame.origin, to: nil) ?? CGPoint.zero
        endOrigin.y -= navigationSnapshot?.frame.size.height ?? 0

        securityCodeVC.view.removeFromSuperview()
        containerView.addSubview(oneTapVC.view)
        oneTapVC.view.frame = containerView.bounds
        containerView.addSubview(backgroundView)

        topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
        topView.frame = topView.frame.offsetBy(dx: 0, dy: -fixedFrames.headerFrame.size.height)
        topView.alpha = 0
        footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: footerSnapshot.frame.size.height)
        footerSnapshot.alpha = 0

        var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
        pxAnimator.addAnimation(animation: {
            topViewBackground.frame = topViewBackground.frame.offsetBy(dx: 0, dy: fixedFrames.headerFrame.size.height)
            footerSnapshot.frame = footerSnapshot.frame.offsetBy(dx: 0, dy: -footerSnapshot.frame.size.height)
            footerSnapshot.alpha = 1

            cardSnapshot.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            cardSnapshot.frame.origin = endOrigin
        })

        pxAnimator.addCompletion(completion: {
            var pxAnimator = PXAnimator(duration: 0.5, dampingRatio: 1.0)
            pxAnimator.addAnimation(animation: {
                topView.frame = topView.frame.offsetBy(dx: 0, dy: fixedFrames.headerFrame.size.height)
                topView.alpha = 1
            })

            pxAnimator.addCompletion(completion: {
                backgroundView.removeFromSuperview()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })

            pxAnimator.animate()
        })

        pxAnimator.animate()
    }
}

// Helpers
extension PXOneTapViewControllerTransition {
    private func buildTopView(containerView: UIView, navigationSnapshot: UIView?, headerSnapshot: UIView, footerSnapshot: UIView) -> UIView {
        var topFrame = containerView.frame
        topFrame.size.height -= footerSnapshot.frame.size.height
        let topView = UIView(frame: topFrame)
        if let navigationSnapshot = navigationSnapshot { topView.addSubview(navigationSnapshot) }
        topView.addSubview(headerSnapshot)
        return topView
    }

    private func buildTopViewOverlayColor(color: UIColor?, topView: UIView) -> UIView {
        let topViewOverlay = UIView(frame: topView.frame)
        topViewOverlay.backgroundColor = color
        return topViewOverlay
    }

    private func addTopViewOverlay(topView: UIView, backgroundColor: UIColor?) {
        let topViewOverlay = UIView(frame: topView.frame)
        topViewOverlay.backgroundColor = backgroundColor
        topViewOverlay.alpha = 0
        topView.addSubview(topViewOverlay)
    }

    private func buildFrames(oneTapVC: PXOneTapViewController, containerView: UIView) -> (navigationFrame: CGRect, headerFrame: CGRect, footerFrame: CGRect) {
        // Fix frame sizes and position
        var headerFrame = oneTapVC.headerView?.frame ?? CGRect.zero
        var footerFrame = oneTapVC.whiteView?.frame ?? CGRect.zero

        var navigationFrame = containerView.frame
        navigationFrame.size.height -= (headerFrame.size.height + footerFrame.size.height)
        headerFrame.origin.y = navigationFrame.height
        footerFrame.origin.y = headerFrame.origin.y + headerFrame.size.height

        return (navigationFrame, headerFrame, footerFrame)
    }
}
