//
//  InlineTagController.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import UIKit

public struct Tag {
    var text: String
    var becomeFirstResponder: Bool = false

    init(text: String, becomeFirstResponder: Bool = false) {
        self.text = text
        self.becomeFirstResponder = becomeFirstResponder
    }
}

enum DataSourceError: Error {
    case outOfBounds
}

public protocol InlineTagControllerDelegate: class {
    func inlineTagController(_ controller: InlineTagController, didFinishEditing text: String)
    func inlineTagController(_ controller: InlineTagController, didChange text: String)
}

extension InlineTagControllerDelegate {
    func inlineTagController(_ controller: InlineTagController, didChange text: String) {}
}

// MARK: - Class implementation

public class InlineTagController: UICollectionView {

    public weak var tagDelegate: InlineTagControllerDelegate?

    fileprivate var tags: [Tag] = []
    fileprivate var sizingCell: InlineTagCell!
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var placeholderLabel: UILabel!

    public var stringItems: [String] {
        return self.tags.filter({ (tag: Tag) -> Bool in
            tag.text != ""
        }).map({ (tag: Tag) -> String in
            tag.text
        })
    }

    public var validStrings: [String] {
        return self.tags.filter({ (tag: Tag) -> Bool in
            tag.text != "" && InlineTagControllerValidation.isValid(text: tag.text)
        }).map({ (tag: Tag) -> String in
            tag.text
        })
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.collectionViewLayout = InlineTagControllerFlowLayout()
        self.customInit()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: InlineTagControllerFlowLayout())
        self.customInit()
    }

    override public var intrinsicContentSize: CGSize {
        let size = self.collectionViewLayout.collectionViewContentSize
        return CGSize(width: self.bounds.width, height: max(self.minimumHeight(), size.height))
    }

    public func setConfiguration(_ config: InlineTagConfigurable) {
        Config.instance.set(config: config)
        updateForConfig()
    }

    private func customInit() {
        self.backgroundColor = UIColor.white
        var frame = self.bounds
        frame.size.height = minimumHeight()

        placeholderLabel = UILabel(frame: frame.insetBy(dx: 20, dy: 0))
        let view = UIView(frame: frame)
        view.addSubview(self.placeholderLabel)

        self.backgroundView = view
        self.register(InlineTagCell.self, forCellWithReuseIdentifier: InlineTagCell.identifier)

        self.dataSource = self
        self.delegate = self

        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        self.addGestureRecognizer(self.tapRecognizer)

        updateForConfig()
    }

    private func updateForConfig() {
        sizingCell = InlineTagCell(frame: CGRect(x: 0, y: 0, width: 100, height: CGFloat(TagConfig.cellHeight)))

        if let layout = self.collectionViewLayout as? InlineTagControllerFlowLayout {
            layout.sectionInset = TagConfig.inset
            layout.minimumInteritemSpacing = TagConfig.interitemSpacing
            layout.minimumLineSpacing = TagConfig.lineSpacing
        }

        self.placeholderLabel.font = TagConfig.font.placeholder
        self.placeholderLabel.textColor = TagConfig.fontColor.placeholder
    }

    private func minimumHeight() -> CGFloat {
        let defaultHeight: CGFloat = CGFloat(TagConfig.cellHeight)
        let padding = TagConfig.inset.top + TagConfig.inset.bottom

        return defaultHeight + padding
    }

    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer != self.tapRecognizer {
            return false
        }

        if let view = touch.view, view is InlineTagCell {
            return false
        } else {
            return true
        }
    }

    internal func didTapOnView(_ sender: AnyObject) {
        self.selectLastPossible()
    }

    fileprivate func selectLastPossible() {
        if let last = self.tags.last, last.text == "" || !isTextValid(text: last.text) || self.tags.count == self.needPreciseNumberOfItems() {
            self.cellForItem(at: IndexPath(item: self.tags.count - 1, section: 0))?.becomeFirstResponder()
        } else {
            if self.tags.count == 0 {
                self.placeholderLabel.isHidden = true
            }

            self.tags.append(Tag(text: "", becomeFirstResponder: true))

            self.performBatchUpdates({ () -> Void in
                self.insertItems(at: [IndexPath(item: self.tags.count - 1, section: 0)])
            }) { (finished) -> Void in
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    private func invalidateIntrinsicContentSize(completionBlock: (() -> ())?) {
        if self.intrinsicContentSize != self.bounds.size {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.invalidateIntrinsicContentSize()
            }) { (finished) -> Void in
                completionBlock?()
            }
        } else {
            completionBlock?()
        }
    }

    private func isTextValid(text: String) -> Bool {
        if let validation = TagConfig.itemValidation {
            return validation(text)
        } else {
            return true
        }
    }

    internal func configure(with tags: [Tag]) {
        self.tags = tags

        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.collectionViewLayout.invalidateLayout()
            self.invalidateIntrinsicContentSize()
        }

        self.reloadData()
        CATransaction.commit()
    }

    public func setTags(_ tags: [String]) {
        // Set new items
        let tagItems = tags.map { (tag: String) -> Tag in
            return Tag(text: tag)
        }

        self.configure(with: tagItems)
    }

    public func setPlaceholderText(text: String) {
        self.placeholderLabel.text = text
    }

}

// MARK: - Text manipulation

extension InlineTagController {

    private func replaceItemsTextAtPosition(position: Int, withText text: String, resign: Bool = true, completion: (() -> ())? = nil) throws {
        if position < 0 || position >= self.tags.count {
            throw DataSourceError.outOfBounds
        }

        self.tags[position].text = text

        guard let cell = self.cellForItem(at: IndexPath(item: position, section: 0)) as? InlineTagCell else {
            completion?()
            return
        }

        cell.configure(with: self.tags[position])

        self.needUpdateLayout(cell: cell) {
            self.invalidateIntrinsicContentSize()

            if resign {
                _ = cell.resignFirstResponder()
            }

            completion?()
        }
    }

    private func replaceLastInvalidOrInsertItemText(text: String, switchToNext: Bool = true, completion: (() -> ())? = nil) {
        if let validator = TagConfig.itemValidation, let tag = self.tags.last, !validator(tag.text) {
            let position = self.tags.index(where: { (i) -> Bool in
                i.text == tag.text
            })

            // Force try because we know that this position exists
            try! self.replaceItemsTextAtPosition(position: position!, withText: text) {
                if switchToNext { self.selectLastPossible() }
                completion?()
            }

            return
        }

        _ = addStringItem(text: text) {
            if switchToNext {
                self.selectLastPossible()
            }
            completion?()
        }
    }

    /// Adds item if possible, returning Bool indicates success or failure
    private func addStringItem(text: String, completion: (()->())? = nil) -> Bool {
        if self.tags.count == self.needPreciseNumberOfItems() && self.tags.last?.text != "" {
            return false
        }

        if self.tags.last != nil && self.tags.last?.text == "" {
            self.tags[self.tags.count - 1].text = text

            if let cell = self.cellForItem(at: IndexPath(item: self.tags.count - 1, section: 0)) as? InlineTagCell {
                cell.configure(with: self.tags[self.tags.count - 1])
            }
        } else {
            self.tags.append(Tag(text: text))

            self.performBatchUpdates({ () -> Void in
                let newLastIndexPath = IndexPath(item: self.tags.count - 1, section: 0)
                self.insertItems(at: [newLastIndexPath])
            }) { (finished) -> Void in
                self.invalidateIntrinsicContentSize()
                completion?()
            }
        }

        return true
    }

    private func removeStringItem(text: String) -> Bool {
        let index = self.tags.index { (tag: Tag) -> Bool in
            tag.text == text
        }

        guard let i = index else {
            return false
        }

        self.tags.remove(at: i)

        self.performBatchUpdates({ () -> Void in
            let newLastIndexPath = IndexPath(item: i, section: 0)
            self.deleteItems(at: [newLastIndexPath])
        }) { (finished) -> Void in
            self.invalidateIntrinsicContentSize()
        }
        
        return true
    }

}

// MARK: - Collection view delegates

extension InlineTagController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InlineTagCell = collectionView.dequeueReusableCell(withReuseIdentifier: InlineTagCell.identifier, for: indexPath) as! InlineTagCell
        cell.delegate = self;

        let tag = tags[indexPath.item]
        cell.configure(with: tag)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var item = self.tags[indexPath.item]

        if item.becomeFirstResponder {
            cell.becomeFirstResponder()
            item.becomeFirstResponder = false
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = self.tags[indexPath.item]

        sizingCell.textField.text = tag.text
        let size = sizingCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        let layoutInset = (self.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        let maximumWidth = self.bounds.width - layoutInset.left - layoutInset.right

        return CGSize(width: min(size.width, maximumWidth), height: CGFloat(TagConfig.cellHeight))
    }
    
}

// MARK: InlineTagCell delegate

extension InlineTagController: InlineTagCellDelegate {

    internal func didChangeText(cell: InlineTagCell, text: String) {
        if let indexPath = self.indexPath(for: cell) {
            self.tags[indexPath.item].text = text
        }

        self.tagDelegate?.inlineTagController(self, didChange: text)
    }

    internal func needUpdateLayout(cell: InlineTagCell) {
        self.needUpdateLayout(cell: cell, completion: nil)
    }

    internal func needUpdateLayout(cell: InlineTagCell, completion: (() -> ())?) {
        self.collectionViewLayout.invalidateLayout()

        // Update cell frame by its intrinsic size
        var frame = cell.frame
        frame.size.width = cell.intrinsicContentSize.width
        cell.frame = frame

        self.invalidateIntrinsicContentSize()
    }

    internal func createAndSwitchToNewCell(cell: InlineTagCell) {
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }

        if cell.textField.text == "" { return }
        cell.set(mode: .view)

        if let preciseNumber = self.needPreciseNumberOfItems(), self.tags.count == preciseNumber {
            _ = cell.resignFirstResponder()
            return
        }

        // Create indexPath for the last item
        let newIndexPath = IndexPath(item: self.tags.count - 1, section: indexPath.section)

        // If the next cell is empty, move to it. Otherwise create new.
        if let nextCell = self.cellForItem(at: newIndexPath) as? InlineTagCell, nextCell.textField.text == "" {
            _ = nextCell.becomeFirstResponder()
        } else {
            self.tags.append(Tag(text: "", becomeFirstResponder: true)) // insert new data item

            // Update collectionView
            self.performBatchUpdates({ () -> Void in
                let newIndexPath = IndexPath(item: self.tags.count - 1, section: indexPath.section)
                self.insertItems(at: [newIndexPath])
            }) { (finished) -> Void in
                self.invalidateIntrinsicContentSize()
                //_ = self.cellForItem(at: newIndexPath)?.becomeFirstResponder()
            }
        }
    }

    internal func needPreciseNumberOfItems() -> Int? {
        switch TagConfig.numberOfTags {
        case .unlimited:
            return nil
        case let .quantity(value):
            return value
        }
    }

    internal func editingDidEnd(cell: InlineTagCell, text: String) {
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }

        if text == "" {
            self.tags.remove(at: indexPath.item)

            self.performBatchUpdates({ () -> Void in
                self.deleteItems(at: [indexPath])
            }) { (finished) -> Void in
                self.invalidateIntrinsicContentSize()

                if self.tags.count == 0 {
                    self.placeholderLabel.isHidden = false
                }
            }
        } else {
            self.tagDelegate?.inlineTagController(self, didFinishEditing: text)
        }
    }

    internal func shouldDeleteCellInFrontOfCell(cell: InlineTagCell) {
        guard let cellsIndexPath = self.indexPath(for: cell) else {
            assertionFailure("There should be a index for that cell!")
            return
        }

        let itemIndex = cellsIndexPath.item
        if itemIndex == 0 {
            return
        }

        let previousItemIndex = itemIndex - 1

        do {
            try self.removeItemAtIndex(index: previousItemIndex, completion: {
                self.tagDelegate?.inlineTagController(self, didChange: "")
            })
        } catch DataSourceError.outOfBounds {
            print("Error occured while removing item")
        } catch { // default
            print("Unknown error occured")
        }
    }

    internal func removeItemAtIndex(index: Int, completion: (() -> ())?) throws {
        if self.tags.count <= index || index < 0 {
            throw DataSourceError.outOfBounds
        }

        self.tags.remove(at: index)

        // Update collectionView
        self.performBatchUpdates({ () -> Void in
            self.deleteItems(at: [IndexPath(item: index, section: 0)])
        }) {[weak self] (finished) -> Void in
            self?.invalidateIntrinsicContentSize()
            completion?()
        }
    }
    
}
