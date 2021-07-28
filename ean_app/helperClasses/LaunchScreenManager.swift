//
//  LaunchScreenManager.swift
//  
//
//  Created by Michał Hęćka on 02/02/2020.
//

import UIKit

class LaunchScreenManager {
    
    static let instance = LaunchScreenManager(animationDurationBase: 1.3)
    
    var view : UIView?
    var parentView : UIView?
    
    let animationDurationBase : Double
    
    init(animationDurationBase: Double) {
        self.animationDurationBase = animationDurationBase
    }
    
    func animateAfterLaunch(_ parentViewPassedIn: UIView) {
        parentView = parentViewPassedIn
        view = loadView()

        fillParentViewWithView()
        
        animateViews()
    }

    func loadView() -> UIView {
        return UINib(nibName: "LaunchScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    func fillParentViewWithView() {
        parentView!.addSubview(view!)

        view!.frame = parentView!.bounds
        view!.center = parentView!.center
    }
    
    func animateViews(){
        
        
        
        
    
        let segment = view?.viewWithTag(1)
        let segmentTop = view?.viewWithTag(2)
        
        
        
        
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            segment?.transform = CGAffineTransform.identity.translatedBy(x: 0, y: (segment?.frame.height)!)
            segmentTop?.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -(segmentTop?.frame.height)!)
        }) { (move) in
            self.view?.removeFromSuperview()
        }
        
        
        
    }
    
}
