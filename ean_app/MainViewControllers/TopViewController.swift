//
//  TopViewController.swift
//  ean_app
//
//  Created by Michał Hęćka on 02/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import CoreData


class TopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    weak var delegate : ShowProductDelegate?
    
    var titles = [Items]()
    let cellId = "productCell"
    var eanToPass = ""
    
    let versionText = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    let buildText = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    
    let productBase = ProductBase()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var appVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        
        self.collectionView.addGestureRecognizer(longPress)
        titles = productBase.loadContext()
        
        appVersion.text =  "\(versionText!) (\(buildText!))"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProductCell
           
        cell.productImage.image = UIImage(data: titles[indexPath.row].image! , scale: 1.0)
        cell.productTitle.text = titles[indexPath.row].title
        return cell
    }
    
    @objc func handleLongPress(longPressGR : UILongPressGestureRecognizer){
        if longPressGR.state == .ended{
            return
        }
        
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            var cell = self.collectionView.cellForItem(at: indexPath)
                let alert = UIAlertController(title: "Delete this item?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                    if let result = try? self.context.fetch(Items.fetchRequest()) {
                        for object in result {
                            self.context.delete(self.titles[indexPath.row])
                        }
                        self.productBase.saveContext()
                        self.titles = self.productBase.loadContext()
                        self.collectionView.reloadData()
        
                    }
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
        else{
            print("index path not found")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        eanToPass = titles[indexPath.row].ean!
        
        performSegue(withIdentifier: "showProductFromTop", sender: self)
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showProductFromTop":
            let vc = segue.destination as! ProductViewController
            vc.ean = eanToPass
            break
        default:
            break
        }
    }
}

public protocol ShowProductDelegate : class{
    func showProductFromTop(ean : String)
}
