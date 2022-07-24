//
//  CustomLayoutForCard.swift
//  EkaAnalytics
//
//  Created by Nithin on 23/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation
import  UIKit

class CustomLayoutForCard: UICollectionViewLayout{
 
    //Public Customizable properties
    public var cellHeight:CGFloat = 50
    
    //MARK: - Private properties
    private var contentHeight: CGFloat  = 0
    private var itemSize : CGSize!
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private func clearCache(){
        cache.removeAll()
    }
    
    override func prepare() {
        super.prepare()
        
        if cache.isEmpty{
            
            itemSize = CGSize(width: self.collectionView!.frame.size.width, height: cellHeight)
            
            let totalCount = collectionView!.numberOfItems(inSection: 0)
            
            contentHeight = CGFloat(totalCount) * cellHeight
            
            let centerYPoint = self.collectionView!.frame.size.height/2
            
            var initialCellYPosition:CGFloat = 0
            
            if contentHeight <= self.collectionView!.frame.size.height{
                initialCellYPosition = centerYPoint - ((CGFloat(totalCount)/2)*cellHeight)
            }
            
            cache = (0 ..< self.collectionView!.numberOfItems(inSection: 0)).map({ (i:Int) -> UICollectionViewLayoutAttributes in
                
                let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
                
                    attribute.frame = CGRect(x: 0, y: initialCellYPosition + (CGFloat(i)*cellHeight), width: self.collectionView!.frame.size.width, height: cellHeight)
                    
                    return attribute
            })
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row]
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionView!.frame.size.width , height: contentHeight)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        clearCache()
    }
    
}
