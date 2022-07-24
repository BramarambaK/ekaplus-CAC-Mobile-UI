//
//  CompositeTabView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 19/05/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class CompositeTabView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK: - Variable
    var tabBarDataSource:[String] = []
    var ls_SelectedCardTab:Int?
    var delegate:AdvancedCompositeDelegate?
    
    //MARK: - IBOutlet
    @IBOutlet weak var tabCollectionView: UICollectionView!

    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: CompositeTabView.self), owner: self, options: nil)?.first as! CompositeTabView
        return view as! Self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabBarDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        tabCollectionView.register(UINib.init(nibName: "CompositeTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CompositeTabCollectionViewCell.identifier)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompositeTabCollectionViewCell.identifier, for: indexPath) as! CompositeTabCollectionViewCell
        cell.tag = indexPath.row
        cell.config(ls_CardSelectedTab: ls_SelectedCardTab ?? 0)
        cell.lbl_TabValue.text = tabBarDataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: tabCollectionView.frame.width/3.5, height:40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.ls_SelectedCardTab = indexPath.row
        delegate?.updateSelectedTab(SelectedTab: indexPath.row)
        tabCollectionView.reloadData()
    }
}
