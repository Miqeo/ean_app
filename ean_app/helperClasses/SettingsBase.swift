//
//  SettingsBase.swift
//  ean
//
//  Created by Michał Hęćka on 02/02/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import CoreData

class SettingsBase : NSObject {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadContext(with request : NSFetchRequest<Settings> = Settings.fetchRequest() ) -> [Settings] {
        
        var allergensBase = [Settings]()
        do{
            allergensBase = try context.fetch(request)
            
        }
        catch{
            print("Error fetching data from context \(error)")
            allergensBase = []
        }
        
        return allergensBase
    }
    
    func saveContext(){
        do{
            try context.save()
        }
        catch{
            print("Error saving context : \(error)")
        }
    }
    
    
    func prepareToSaveAllergen(name : String){
        
        let allerg = Settings(context: context)
        allerg.name = name
        allerg.state = true
        
    }
}
