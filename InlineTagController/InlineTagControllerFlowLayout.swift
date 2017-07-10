//
//  InlineTagControllerFlowLayout.swift
//  Testing
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import UIKit

class InlineTagControllerFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let array = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        let newArray = array.map { (element) -> UICollectionViewLayoutAttributes in
            let attributes = element.copy() as! UICollectionViewLayoutAttributes

            if attributes.representedElementKind == nil {
                let indexPath = attributes.indexPath
                attributes.frame = (self.layoutAttributesForItem(at: indexPath)?.frame)!
            }

            return attributes
        }

        return newArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)!.copy() as! UICollectionViewLayoutAttributes
        var frame = attributes.frame

        if attributes.frame.origin.x <= self.sectionInset.left {
            return attributes
        }

        if indexPath.item == 0 {
            frame.origin.x = self.sectionInset.left
        } else {
            let prevIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            let prevAttributes = self.layoutAttributesForItem(at: prevIndexPath)!

            if attributes.frame.origin.y > prevAttributes.frame.origin.y {
                frame.origin.x = self.sectionInset.left
            } else {
                frame.origin.x = prevAttributes.frame.maxX + self.minimumInteritemSpacing
            }
        }
        
        attributes.frame = frame
        return attributes
    }

}
