//
//  ContainerViewController.swift
//  ean_app
//
//  Created by Michał Hęćka on 02/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    enum SlidOutState {
        case bothCollapsed
        case topExpanded
        case bottomExpanded
    }

    //those hold center vc and its parent navigation c
    var centerNavigationController: UINavigationController!
    var centerViewController: MainViewController!//they are optional because they wont be initialized until init()
    
    var currentState : SlidOutState = .bothCollapsed//start state
    var upViewController : TopViewController?//holds up vc
    
    let centerExpandedOffset : CGFloat = 240//height thats is visible once it has animated of screen
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDark ? .lightContent : .default
    }
    
    var isDark = true {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        centerViewController = UIStoryboard.centerViewController()//getting center vc from storyboard
        centerViewController.delegate = self//self is delegate of center vc so center vc can notify itself to show and hide up vc
        
        //creating center nc so it can push views to it and display bar with buttons
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.navigationBar.barStyle = .black
        
        centerNavigationController.navigationBar.isHidden = true
        //adding center nc view to container vc's view
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)

        //setting parent child relationship
        centerNavigationController.didMove(toParent: self)
        
        
        
        //creating assigning self as the target and handle pan as selector to detect
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    

    

}
//to conform to UIGestureRecognizerDelegate
extension ContainerViewController : UIGestureRecognizerDelegate{
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer){
        
        let gestureIsDraggingFromTopToBottom = (recognizer.velocity(in: view).y > 0)//interested only in vertical movement
        
        switch recognizer.state {
        //touch began
        case .began:
            if currentState == .bothCollapsed{
                if gestureIsDraggingFromTopToBottom{
                    addUpPanelViewController()
                    
                }
                else {
                    recognizer.isEnabled = false//only movement from top to bottom when .collapsed
                }
            }
        //touch moved
        case .changed:
            
            if let rview = recognizer.view {
                
                rview.center.y = rview.center.y + recognizer.translation(in: view).y
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        //touch not present
        case .ended:
            if let _ = upViewController, let rview = recognizer.view{//depending if view underneath is visible
                let movedGreaterThanHalf = rview.center.y > view.bounds.size.height - centerExpandedOffset
                animateUpPanel(shouldExpand: movedGreaterThanHalf)
                
            }
        default:
            break
        }
        recognizer.isEnabled = true
    }
}

private extension UIStoryboard {
  static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> TopViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "SidePanelViewController") as? TopViewController
  }
  
  static func centerViewController() -> MainViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "CenterViewController") as? MainViewController
  }
}
//so it can conform to protocol center vc delegate
extension ContainerViewController : CenterViewControllerDelegate{
    
    
    func toggleUpPanel() {
        let notAlreadyExpanded = (currentState != .topExpanded)// if its expanded then false
        
        if notAlreadyExpanded {
            addUpPanelViewController()
            
        }
                
        animateUpPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addUpPanelViewController(){
        //if up vc is nil then creates new new SidepanelViewController
        guard upViewController == nil else { return }
        
        if let vc = UIStoryboard.leftViewController() {
            
            addChildSidePanelController(vc)
            upViewController = vc
        }
    }
    
    func animateUpPanel(shouldExpand : Bool){
        if shouldExpand {//opens
            currentState = .topExpanded
            let addon = self.centerNavigationController.view.safeAreaInsets.top
            animateCenterPanelYPosition(targetPosition: centerExpandedOffset + addon)
            isDark = false
        }
        else {//closes
            
            animateCenterPanelYPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                self.upViewController?.view.removeFromSuperview()
                self.upViewController = nil
                self.isDark = true
            }
            
        }
        
    }

    func collapseSidePanels() {
        switch currentState {
        case .topExpanded:
            toggleUpPanel()
        case .bothCollapsed:
            break
        case .bottomExpanded:
            break
        }
    }
    
    
    func animateCenterPanelYPosition(targetPosition : CGFloat, comletion : ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            self.centerNavigationController.view.frame.origin.y = targetPosition
            
        }, completion: comletion)  }
    
    func addChildSidePanelController( _ sidePanelController : TopViewController){
        //adds child vc to container vc, inserts its view at z 0 that means below center view controller
        view.insertSubview(sidePanelController.view, at: 0)
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
}
