//
//  IntroPageViewController.swift
//  EkaAnalytics
//
//  Created by GoodWorkLabs Services Private Limited on 15/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//




import UIKit

class IntroPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
	
	@IBOutlet weak var collectionView:UICollectionView!
	@IBOutlet weak var btnSkip:UIButton!
	@IBOutlet weak var pageControl:UIPageControl!
	
	var contentSource = [String]()
	var imageSource = [String]()
    
    var visibleRows = [IndexPath]()
	
	var cellSize:CGSize = CGSize.zero {
		didSet{
			collectionView.collectionViewLayout.invalidateLayout()
		}
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        SecurityUtilities().ExitOnJailbreak()
        
		// Do any additional setup after loading the view.
		contentSource = ["Discover accurate and actionable insights from your data with Eka's Intelligence Engine", "Integrate multiple systems seamlessly across business processes with Eka's Data Connectors", "Tell your story the way you want to with prebuilt and high-value apps or create your own apps"]
		
		imageSource = ["Group 18","Combined Shape", "Group 19"]
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.showsHorizontalScrollIndicator = false

		collectionView.reloadData()
		
	}
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
   
        coordinator.animate(alongsideTransition: { context in
            // Save the visible row position
            self.visibleRows = self.collectionView.indexPathsForVisibleItems
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
        }, completion: { context in
            // Scroll to the saved position prior to screen rotate
        
            self.collectionView.scrollToItem(at: self.visibleRows[0], at: .centeredHorizontally, animated: false)
        })
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).invalidateLayout()
    }
	
	@IBAction func skipButtonAction(_ sender: UIButton) {

        let rootNavVC = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
//        rootNavVC.isNavigationBarHidden = true
        rootNavVC.view.alpha = 0
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let domainVC = storyBoard.instantiateViewController(withIdentifier: "DomainViewController") as! DomainViewController
        rootNavVC.pushViewController(domainVC, animated: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = rootNavVC
        
        let snapshot = self.view.snapshotView(afterScreenUpdates: true)!
        appDelegate.window?.addSubview(snapshot)
        
        UIView.animate(withDuration: 0.35, animations: {
            snapshot.alpha = 0
            rootNavVC.view.alpha = 1
        }) { (completed) in
            snapshot.removeFromSuperview()
        }
        
	}
    
    @objc
    func signUpAction(_ sender: UIButton){

        skipButtonAction(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.present(signUpVC, animated: true, completion: nil)
        }
        
    }
	
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//
////        let index = Int(self.view.frame.width/scrollView.contentOffset.x)
//
//    }
	
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x/self.view.frame.width)
        pageControl.currentPage = currentIndex
        if currentIndex == contentSource.count{
            self.btnSkip.isHidden = true
        }else{
            self.btnSkip.isHidden = false
        }
    }
	
	
	//MARK: - Collection view datasource and delegates
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return contentSource.count + 1 //we have one extra login page
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroCollectionViewCell.reuseIdentifier, for: indexPath) as? IntroCollectionViewCell, indexPath.item < contentSource.count {
        
            let image = UIImage(named: imageSource[indexPath.item])!
            let content = NSLocalizedString(contentSource[indexPath.item], comment: "No Intro Content")
            
            
            
            cell.setUp(image: image, content: content)
            return cell
            
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroLoginCollectionViewCell.reuseIdentifier, for: indexPath) as? IntroLoginCollectionViewCell {
            
            cell.btnLogin.addTarget(self, action: #selector(self.skipButtonAction(_:)), for: .touchUpInside)
            cell.btnSignUp.addTarget(self, action: #selector(self.signUpAction(_:)), for: .touchUpInside)
            return cell
        }
        
        return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
		
		return collectionView.frame.size
	
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
	
	
}


