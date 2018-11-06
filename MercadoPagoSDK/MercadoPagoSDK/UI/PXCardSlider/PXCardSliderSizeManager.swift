//
//  PXCardSliderSizeManager.swift
//
//  Created by Juan sebastian Sanzone on 12/10/18.
//

import UIKit

struct PXCardSliderSizeManager {

    static func getHeaderViewHeight(viewController: UIViewController) -> CGFloat {
        if UIDevice.isSmallDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 32)
        } else {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 40)
        }
    }

    static func getWhiteViewHeight(viewController: UIViewController) -> CGFloat {
        if UIDevice.isSmallDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 68)
        } else {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 60)
        }
    }

    static func getItemSize() -> CGSize {
        if UIDevice.isSmallDevice() {
            return getSizeByGoldenAspectRatio(width: 290)
        } else if UIDevice.isLargeDevice() {
            return getSizeByGoldenAspectRatio(width: 340)
        } else if UIDevice.isExtraLargeDevice() {
            return getSizeByGoldenAspectRatio(width: 380)
        } else {
            return getSizeByGoldenAspectRatio(width: 340)
        }
    }

    static func getSizeByGoldenAspectRatio(width: CGFloat) -> CGSize {
        let goldenAspectRation: CGFloat = 1.586
        let size = CGSize(width: width, height: width / goldenAspectRation)
        return size
    }

    static func getItemContainerSize() -> CGSize {
        return CGSize(width: getItemSize().width - 20, height: getItemSize().height - 20)
    }

    static func getSliderSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: getItemSize().height)
    }
}
