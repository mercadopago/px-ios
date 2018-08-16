//
//  PXInstructionsComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
public class PXInstructionsComponent: NSObject, PXComponentizable {
    var props: PXInstructionsProps

    init(props: PXInstructionsProps) {
        self.props = props
    }

    func getSubtitleComponent() -> PXInstructionsSubtitleComponent? {
        let instructionsSubtitleProps = PXInstructionsSubtitleProps(subtitle: props.instruction.subtitle!)
        let instructionsSubtitleComponent = PXInstructionsSubtitleComponent(props: instructionsSubtitleProps)
        return instructionsSubtitleComponent
    }

    func getContentComponent() -> PXInstructionsContentComponent? {
        let instructionsContentProps = PXInstructionsContentProps(instruction: props.instruction)
        let instructionsContentComponent = PXInstructionsContentComponent(props: instructionsContentProps)
        return instructionsContentComponent
    }

    func getSecondaryInfoComponent() -> PXInstructionsSecondaryInfoComponent? {
        let instructionsSecondaryInfoProps = PXInstructionsSecondaryInfoProps(secondaryInfo: props.instruction.secondaryInfo!)
        let instructionsSecondaryInfoComponent = PXInstructionsSecondaryInfoComponent(props: instructionsSecondaryInfoProps)
        return instructionsSecondaryInfoComponent
    }

    public func hasSubtitle() -> Bool {
        return props.instruction.subtitle != nil
    }

    public func hasSecondaryInfo() -> Bool {
        return !Array.isNullOrEmpty(props.instruction.secondaryInfo)
    }

    public func shouldShowEmailInSecondaryInfo() -> Bool {
        return MercadoPagoCheckoutViewModel.servicePreference.shouldShowEmailConfirmationCell()
    }

    public func render() -> UIView {
        return PXInstructionsRenderer().render(self)
    }
}

/** :nodoc: */
public class PXInstructionsProps: NSObject {
    var instruction: Instruction
    init(instruction: Instruction) {
        self.instruction = instruction
    }
}
