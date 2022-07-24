//
//  AppsViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

/*

enum TabMenu:String{
    case Apps
    case MyApps
}

class AppsViewControllerContainer: UIViewController {
    
    var currentlySelectedTab:TabMenu! {
        didSet{
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("AppsListViewController"),
                self.newViewController("AppsListViewController")]
    }()
    
    private func newViewController(_ identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(identifier)")
    }
    
    @IBOutlet weak var appsSelectionConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myAppsSelectionConstraint: NSLayoutConstraint!
    
    var pageViewController : UIPageViewController? {
        return self.childViewControllers.first as? UIPageViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectApps()
        self.pageViewController?.delegate = self
        self.pageViewController?.dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            self.pageViewController?.setViewControllers([firstViewController],
                                                        direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    
    func selectApps(){
        myAppsSelectionConstraint.isActive = false
        appsSelectionConstraint.isActive = true
        currentlySelectedTab = .Apps
        pageViewController?.setViewControllers([orderedViewControllers.first!], direction: .reverse, animated: true, completion: nil)
    }
    func selectMyApps(){
        appsSelectionConstraint.isActive = false
        myAppsSelectionConstraint.isActive = true
        
        currentlySelectedTab = .MyApps
        pageViewController?.setViewControllers([orderedViewControllers.last!], direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func toggleSelection(_ sender: UIButton) {
        sender.tag == 0 ? selectApps() : selectMyApps()
    }
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {_ in self.currentlySelectedTab == .Apps ? self.selectApps() : self.selectMyApps()}, completion: nil)
        
    }
  
}


extension AppsViewControllerContainer:UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
 
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentlySelectedTab == .Apps ? selectMyApps() : selectApps()
        }
    }
}

 */
