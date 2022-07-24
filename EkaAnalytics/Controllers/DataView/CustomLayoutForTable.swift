//
//  CustomLayoutForTable.swift
//  EkaAnalytics
//
//  Created by Nithin on 02/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

protocol CustomLayoutDelegateForTable : AnyObject {
    func widthForColumn(_ column:Int)->CGFloat
}

class CustomLayoutForTable: UICollectionViewLayout{
    
    //Public Customizable properties
    public var cellHeight:CGFloat = 30
    public var numberOfColumns:Int = 3
    public var horizontalCellSpacing:CGFloat = 1
    public var verticalCellSpacing:CGFloat = 1
    weak var delegate:CustomLayoutDelegateForTable?
    
    //MARK: - Private properties
    private var defaultCellWidth:CGFloat = 500
    private var contentSize: CGSize = CGSize.zero
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private func clearCache(){
        cache.removeAll()
    }
    
    override func prepare() {
        super.prepare()
        
        if cache.isEmpty{
            
            let totalCount = collectionView!.numberOfItems(inSection: 0)
            
            let numberOfRows = CGFloat(totalCount)/CGFloat(numberOfColumns)
            
            var contentSizeWidth:CGFloat = 0
            
            for i in 0..<numberOfColumns{
                let columnWidth = delegate?.widthForColumn(i) ?? defaultCellWidth
                contentSizeWidth += columnWidth
            }
            
            contentSizeWidth += CGFloat(numberOfColumns-1)*horizontalCellSpacing
            
            contentSize = CGSize(width: contentSizeWidth, height: numberOfRows*cellHeight)
            
            var initialXPosition:CGFloat = 0
            
            cache = (0 ..< self.collectionView!.numberOfItems(inSection: 0)).map({ (i:Int) -> UICollectionViewLayoutAttributes in
                
                let indexPath = IndexPath(item: i, section: 0)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                let currentRow = indexPath.item/Int(numberOfColumns)
                let currentColumn = CGFloat(indexPath.item - numberOfColumns*currentRow)
                
                if initialXPosition >= contentSizeWidth {
                    initialXPosition = 0
                }
                
                let xPos = initialXPosition
                let yPos = (CGFloat(currentRow)*cellHeight + CGFloat(currentRow)*verticalCellSpacing)
                
                attribute.frame = CGRect(x: xPos, y: yPos , width:(delegate?.widthForColumn(Int(currentColumn)) ?? defaultCellWidth) , height: cellHeight)
                
                initialXPosition += ((delegate?.widthForColumn(Int(currentColumn)) ?? defaultCellWidth) + horizontalCellSpacing)
                
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
        return contentSize
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        clearCache()
    }
    
}
