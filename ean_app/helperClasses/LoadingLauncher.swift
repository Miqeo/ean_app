//
//  Loading.swift
//  ean
//
//  Created by Michał Hęćka on 18/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit


class LoadingLauncher: NSObject {
    let backgroundView = UIView()
    let loading = UIActivityIndicatorView()
    
    func showLoading(){
        
        if let window = UIApplication.shared.keyWindow{
            
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            backgroundView.frame = window.frame
            
            loading.color = UIColor.init(named: "AccentColor")
            loading.startAnimating()
            loading.frame = CGRect(x: window.frame.size.width / 2, y: window.frame.size.height / 2, width: 30, height: 30)
            let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            loading.transform = transform
            loading.center = backgroundView.center
            
            
            window.addSubview(backgroundView)
            window.addSubview(loading)
        }
    }
    
    func removeLoading(){
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 0
            self.loading.alpha = 0
        }, completion: nil)
        
    }
    
}
