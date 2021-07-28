//
//  ProductBase.swift
//  ean
//
//  Created by Michał Hęćka on 02/02/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import CoreData

class ProductBase : NSObject{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadContext(with request : NSFetchRequest<Items> = Items.fetchRequest() ) -> [Items]{
        
        
        var titles = [Items]()
        
        do{
            titles = try context.fetch(request)
            
        }
        catch{
            print("Error fetching data from context \(error)")
            titles = []
        }
        
        return titles
    }
    
    func saveContext(){
        do{
            try context.save()
        }
        catch{
            print("Error saving context : \(error)")
        }
    }
    
    func prepareToSaveItem(ean : String, name : String = "Product", image : UIImage = UIImage.init(named: "mm")!){
        
        let item = Items(context: context)
        item.ean = ean
        item.title = name
        item.image = image.jpegData(compressionQuality: 1.0)
        
    }
    
}
