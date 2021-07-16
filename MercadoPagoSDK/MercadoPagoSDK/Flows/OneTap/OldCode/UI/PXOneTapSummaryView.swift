//
//  PXOneTapSummaryView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

class PXOneTapSummaryView: PXComponentView {
    private var data: [PXOneTapSummaryRowData] = [] {
        willSet {
            if data.count > newValue.count {
                removeSummaryRows(oldValue: data, newValue: newValue, animated: true)
            } else if data.count < newValue.count {
                addSummaryRows(oldValue: data, newValue: newValue, animated: true)
            } else if animationIsNeeded(newData: newValue) {
                let rowsToMove = rows.filter{ !$0.data.isTotal }
                let distanceArray = getDistanceArray(rowsToMove)
                animateRows([PXOneTapSummaryRow](), rowsToMove: rowsToMove, newData: newValue, animateIn: true, distance: 0, distanceArray: distanceArray) {}
            } else {
                updateAllRows(newData: newValue)
            }
        }
    }
    private weak var delegate: PXOneTapSummaryProtocol?
    private var rows: [PXOneTapSummaryRow] = []
    private var currentAnimator: UIViewPropertyAnimator?
    private var splitMoney: Bool

    init(data: [PXOneTapSummaryRowData] = [], delegate: PXOneTapSummaryProtocol, splitMoney: Bool = false) {
        self.data = data.reversed()
        self.delegate = delegate
        self.splitMoney = splitMoney
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render() {
        self.removeAllSubviews()
        self.pinContentViewToBottom()
        self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        var offset: CGFloat = 0
        for row in self.data {
            row.splitMoney = splitMoney
            let rowView = self.getSummaryRowView(with: row)
            let margin = rowView.getRowMargin()

            offset += margin

            self.addSubview(rowView)
            let rowViewConstraint = PXLayout.pinBottom(view: rowView, withMargin: offset)

            offset += rowView.getRowHeight()

            self.rows.append(PXOneTapSummaryRow(data: row, view: rowView, constraint: rowViewConstraint, rowHeight: rowView.getTotalHeightNeeded()))

            if row.isTotal {
                let separatorView = UIView()
                separatorView.backgroundColor = ThemeManager.shared.boldLabelTintColor()
                separatorView.alpha = 0.1
                separatorView.translatesAutoresizingMaskIntoConstraints = false

                self.addSubview(separatorView)
                PXLayout.pinBottom(view: separatorView, withMargin: offset).isActive = true
                PXLayout.setHeight(owner: separatorView, height: 1).isActive = true
                PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinRight(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                offset += PXLayout.S_MARGIN
                self.bringSubviewToFront(rowView)
            }

            PXLayout.centerHorizontally(view: rowView).isActive = true
            PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true
        }
    }

    func tapRow(_ sender: UITapGestureRecognizer) {
        if let rowView = sender.view as? PXOneTapSummaryRowView,
            let type = rowView.getData().type,
            let action = rowAction(for: type) {
                action()
        }
    }

    private func rowAction(for type: PXOneTapSummaryRowView.RowType) -> PXOneTapSummaryRowView.Handler? {
        switch type {
        case .charges:
            return self.delegate?.didTapCharges
        case .discount:
            return self.delegate?.didTapDiscount
        default:
            return nil
        }
    }

    func stopCurrentAnimatorIfNeeded() {
        if let cAnimator = self.currentAnimator {
            cAnimator.stopAnimation(false)
            cAnimator.finishAnimation(at: .end)
        }
    }

    func animateRows(_ rowsToAnimate: [PXOneTapSummaryRow], rowsToMove: [PXOneTapSummaryRow], newData: [PXOneTapSummaryRowData], animateIn: Bool, distance: CGFloat, distanceArray: [CGFloat]? = nil, completion: @escaping () -> Void) {
        let duration: Double = 0.4
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: nil)

        animator.addAnimations {
            self.updateAllRows(newData: newData)
        }

        for (index, row) in rowsToAnimate.enumerated() {
            self.sendSubviewToBack(row.view)
            animator.addAnimations {
                row.view.alpha = animateIn ? 1 : 0
                if distanceArray == nil || distanceArray?.isEmpty ?? true || rowsToMove.count == 2 {
                    row.constraint.constant += animateIn ? -distance : distance
                } else if let distanceArray = distanceArray, index < distanceArray.count, rowsToMove.isEmpty {
                    row.constraint.constant = distanceArray[index]
                }
                self.layoutIfNeeded()
            }
        }

        for (index, mRow) in rowsToMove.enumerated() {
            self.sendSubviewToBack(mRow.view)
            animator.addAnimations {
                if distanceArray == nil || distanceArray?.isEmpty ?? true {
                    mRow.constraint.constant += animateIn ? -distance : distance
                } else if let distanceArray = distanceArray, index < distanceArray.count {
                    mRow.constraint.constant = distanceArray[index]
                }
                self.layoutIfNeeded()
            }
        }

        animator.addCompletion { (_) in
            completion()
        }

        currentAnimator = animator
        animator.startAnimation()
    }

    func removeSummaryRows(oldValue: [PXOneTapSummaryRowData], newValue: [PXOneTapSummaryRowData], animated: Bool) {
        let amountToRemove = oldValue.count - newValue.count
        var indexesToRemove: [Int] = []

        for index in 1...amountToRemove {
            indexesToRemove.append(index)
        }

        var distanceDelta: CGFloat = 0
        var rowsToRemove: [PXOneTapSummaryRow] = []
        var rowsToMove: [PXOneTapSummaryRow] = []

        for (index, row) in rows.enumerated() where !row.data.isTotal {
            if indexesToRemove.contains(index) {
                distanceDelta += row.rowHeight
                rowsToRemove.append(row)
            } else {
                rowsToMove.append(row)
            }
        }

        for row in rowsToRemove {
            if let index = self.rows.firstIndex(of: row) {
                self.rows.remove(at: index)
            }
        }

        var distanceArray: [CGFloat] = []
        if rowsToRemove.count == 1, updateRowConstraintsIfNecessary(oldRows: rowsToMove, newData: newValue) {
            let newDiscountRow = rowsToMove.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount })
            let rowDistance: CGFloat = UIDevice.isSmallDevice() ? PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4 + 24 : PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + 24
            distanceArray.append(-rowDistance)
            if let newDiscountRow = newDiscountRow, newDiscountRow.data.rowHasBrief() {
                var rowHeight: CGFloat
                if newDiscountRow.view.briefHasOneLine() {
                    rowHeight = (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) + PXOneTapSummaryRowView.MARGIN
                    distanceArray.append(-rowDistance - rowHeight)
                } else {
                    rowHeight = (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3) + PXOneTapSummaryRowView.MARGIN
                    distanceArray.append(-rowDistance - rowHeight)
                }
            } else {
                distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN))
            }
        }

        stopCurrentAnimatorIfNeeded()
        animateRows(rowsToRemove, rowsToMove: rowsToMove, newData: newValue, animateIn: false, distance: distanceDelta, distanceArray: distanceArray) {
            for row in rowsToRemove {
                row.view.removeFromSuperview()
            }
        }
    }

    func addSummaryRows(oldValue: [PXOneTapSummaryRowData], newValue: [PXOneTapSummaryRowData], animated: Bool) {
        let amountToAdd = newValue.count - oldValue.count
        var newRowsData: [PXOneTapSummaryRowData] = []

        for index in 1...amountToAdd {
            newRowsData.append(newValue[index])
        }

        var distanceDelta: CGFloat = 0
        var rowsToAdd: [PXOneTapSummaryRow] = []
        var rowsToMove: [PXOneTapSummaryRow] = []

        for (index, rowData) in newRowsData.enumerated() {
            rowData.splitMoney = splitMoney
            let rowView = getSummaryRowView(with: rowData)
            let rowHeight = rowView.getTotalHeightNeeded()
            let totalRowHeight = rows[optional: 0]?.rowHeight ?? 52
            rowView.alpha = 0

            let multiplier = rowHeight * CGFloat(index)
            let constraintConstant: CGFloat = -totalRowHeight - multiplier
            distanceDelta = rowHeight

            //View Constraints
            self.addSubview(rowView)
            let constraint = PXLayout.pinBottom(view: rowView, withMargin: -constraintConstant)

            // Update constraint so as to fix animation when discount row with brief and charges row are shown
            if rowData.type == PXOneTapSummaryRowView.RowType.discount,
                rowData.rowHasBrief(),
                newRowsData.first?.type == PXOneTapSummaryRowView.RowType.charges {
                constraint.constant = -(PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + 24)
            }

            PXLayout.centerHorizontally(view: rowView).isActive = true
            PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true
            self.layoutIfNeeded()

            let newRow = PXOneTapSummaryRow(data: rowData, view: rowView, constraint: constraint, rowHeight: rowHeight)
            rowsToAdd.append(newRow)
            rows.insert(newRow, at: index+1)
        }

        for row in rows where !row.data.isTotal && !newRowsData.contains(row.data) {
            rowsToMove.append(row)
        }

        // Add row to move when passing from 2 rows with charges to 3 rows
        let rowsToUpdate = rows.filter{ $0.data.type == PXOneTapSummaryRowView.RowType.charges }
        if rowsToUpdate.count == 2, rowsToMove.count == 1, let rowToUpdate = rowsToUpdate.last {
            rowsToMove.insert(rowToUpdate, at: 0)
        }

        stopCurrentAnimatorIfNeeded()
        animateRows(rowsToAdd, rowsToMove: rowsToMove, newData: newValue, animateIn: true, distance: distanceDelta, distanceArray: getRowsPositions(rowsToAdd: rowsToAdd, rowsToMove: rowsToMove, newData: newValue)) {
        }
    }

    func updateAllRows(newData: [PXOneTapSummaryRowData]) {
        for (index, row) in rows.enumerated() {
            let newRowData = newData[index]
            row.view.update(newRowData)
            row.updateData(newRowData)
        }
    }

    func update(_ newData: [PXOneTapSummaryRowData], hideAnimatedView: Bool = false) {
        self.data = newData.reversed()
    }

    func updateSplitMoney(_ splitMoney: Bool) {
        self.splitMoney = splitMoney
    }

    func getSummaryRowView(with data: PXOneTapSummaryRowData) -> PXOneTapSummaryRowView {
        let rowView = PXOneTapSummaryRowView(data: data)
        //Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRow(_:)))
        rowView.addGestureRecognizer(tap)
        rowView.isUserInteractionEnabled = true

        return rowView
    }
}

// MARK: Privates
private extension PXOneTapSummaryView {
    func getRowsPositions(rowsToAdd: [PXOneTapSummaryRow]?, rowsToMove: [PXOneTapSummaryRow]?, newData: [PXOneTapSummaryRowData]) -> [CGFloat]? {
        // Animation with discount row from 2 to 3 rows
        var distanceArray = [CGFloat]()
        if rowsToAdd?.count == 1 {
            let rowDistance: CGFloat = UIDevice.isSmallDevice() ? PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4 + (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) + (PXOneTapSummaryRowView.MARGIN * 2) : PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) + (PXOneTapSummaryRowView.MARGIN * 2)
            if let discountRow = rowsToMove?.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount }) {
                distanceArray.append(-rowDistance)
                if let newDiscountRowData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.discount }) {
                    newDiscountRowData.splitMoney = splitMoney
                    discountRow.updateRow(newDiscountRowData)
                    distanceArray.append(-rowDistance - discountRow.view.getTotalHeightNeeded())
                } else {
                    distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN))
                }
                return distanceArray
            } else if let discountRowData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.discount }),
                let rowToMove = rowsToMove?.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.charges }) {
                    discountRowData.splitMoney = splitMoney
                rowToMove.updateRow(discountRowData)
                    distanceArray.append(-rowDistance)
                    distanceArray.append(-rowDistance - rowToMove.view.getTotalHeightNeeded())
                    return distanceArray
            }
            return nil
        }

        guard let rowsToMove = rowsToMove, rowsToMove.isEmpty, let rowsToAdd = rowsToAdd,
              let row = rowsToAdd.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount }), row.data.rowHasBrief()
              else { return nil }

        // Animation with discount row with brief from 0 to 2 or 3 rows
        let rowDistance: CGFloat = UIDevice.isSmallDevice() ? PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4 + 24 : PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + 24
        distanceArray.append(-rowDistance)
        if rowsToAdd.count == 2 {
            // Discount row with brief without charges row
            distanceArray.append(-rowDistance - row.view.getTotalHeightNeeded())
        } else {
            // Discount row with brief with charges row
            distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN))
            distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN) - row.view.getTotalHeightNeeded())
        }
        return distanceArray
    }

    func getDistanceArray(_ rowsToMove: [PXOneTapSummaryRow]) -> [CGFloat] {
        let newRowView = rows.first(where: { $0.data.rowHasBrief() })?.view
        var distanceArray: [CGFloat] = []

        let rowDistance: CGFloat = UIDevice.isSmallDevice() ? PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4 + 24 : PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + 24
        distanceArray.append(-rowDistance)
        if rowsToMove.count == 2 {
            if newRowView == nil {
                distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN))
            } else if let newRowView = newRowView {
                distanceArray.append(-rowDistance - newRowView.getTotalHeightNeeded())
            }
        } else {
            distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN))
            if let newRowView = newRowView {
                distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT + PXOneTapSummaryRowView.MARGIN) - newRowView.getTotalHeightNeeded())
            } else {
                distanceArray.append(-rowDistance - (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3))
            }
        }
        return distanceArray
    }

    func animationIsNeeded(newData: [PXOneTapSummaryRowData]) -> Bool {
        let oldRow = rows.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount })
        let newRowData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.discount })
        newRowData?.splitMoney = splitMoney
        let oldRowNumberOfLines = oldRow?.view.briefNumberOfLines()

        if oldRow == nil && newRowData == nil {
            return false
        } else if let oldRow = oldRow, let newRowData = newRowData {
            if !oldRow.data.rowHasBrief() && !newRowData.rowHasBrief() {
                return false
            } else if oldRow.data.rowHasBrief() && newRowData.rowHasBrief() {
                oldRow.updateRow(newRowData)
                return oldRowNumberOfLines == oldRow.view.briefNumberOfLines() ? false : true
            } else {
                oldRow.updateRow(newRowData)
                return true
            }
        } else if oldRow?.data.rowHasBrief() ?? false || newRowData?.rowHasBrief() ?? false {
            if let newRowData = newRowData,
                let rowToUpdate = rows.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.charges }) {
                // from 2 rows with charges to 2 rows with discounts
                rowToUpdate.updateRow(newRowData)
                return true
            } else if let chargesRowData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.charges }),
                    let oldRow = oldRow {
                    // from 2 rows with discounts to 2 rows with charges
                    chargesRowData.splitMoney = splitMoney
                    oldRow.updateRow(chargesRowData)
                    return true
            }
        }
        return false
    }

    func updateRowConstraintsIfNecessary(oldRows: [PXOneTapSummaryRow], newData: [PXOneTapSummaryRowData]) -> Bool {
        let oldRowToMove = oldRows.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount })
        let newRowToMoveData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.discount })
        newRowToMoveData?.splitMoney = splitMoney

        if oldRowToMove == nil && newRowToMoveData == nil {
            return false
        } else if let oldRowToMove = oldRowToMove, let newRowToMoveData = newRowToMoveData {
            if !oldRowToMove.data.rowHasBrief() && !newRowToMoveData.rowHasBrief() {
                return false
            } else {
                oldRowToMove.updateRow(newRowToMoveData)
                return true
            }
        } else if oldRowToMove?.data.rowHasBrief() ?? false || newRowToMoveData?.rowHasBrief() ?? false {
            if let newChargesRowData = newData.first(where: { $0.type == PXOneTapSummaryRowView.RowType.charges }) {
                // from 3 rows with brief to 2 rows with charges
                oldRowToMove?.updateRow(newChargesRowData)
            }
            return true
        } else {
            // from 3 rows with no brief to 2 rows with charges
            return false
        }
    }
}

// MARK: Publics
extension PXOneTapSummaryView {
    func updateRowsConstraintsIfNecessary() {
        if let row = rows.first(where: { $0.data.type == PXOneTapSummaryRowView.RowType.discount }),
            row.view.overviewBrief != nil,
            row.view.briefHasOneLine() {
            row.view.heightConstraint.constant = PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2
            row.rowHeight = (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) + PXOneTapSummaryRowView.MARGIN
            updatePurchaseRowBottomConstraint()
        }
    }

    private func updatePurchaseRowBottomConstraint() {
        if !UIDevice.isSmallDevice() {
            let bottomConstraintStartingPoint: CGFloat = PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT + 24
            rows.last?.constraint.constant = rows.count == 4 ? -bottomConstraintStartingPoint - (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3) - (PXOneTapSummaryRowView.MARGIN * 2) : -bottomConstraintStartingPoint - (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) - PXOneTapSummaryRowView.MARGIN
        } else {
            let bottomConstraintStartingPoint: CGFloat = PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4 + 24
            rows.last?.constraint.constant = rows.count == 4 ? -bottomConstraintStartingPoint - (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3) - (PXOneTapSummaryRowView.MARGIN * 2) : -bottomConstraintStartingPoint - (PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2) - PXOneTapSummaryRowView.MARGIN
        }
    }
}
