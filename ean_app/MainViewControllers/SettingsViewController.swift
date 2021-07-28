//
//  SettingsViewController.swift
//  ean
//
//  Created by Michał Hęćka on 12/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import CoreData


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let settingsData = ["one","two","three"]
    
    let headers = ["Overall","Allergies"]
    
    var allergens = [Settings]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var settingsTable: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        settingsTable.register(UINib(nibName: "SettingsViewCell", bundle: nil), forCellReuseIdentifier: "settingCell")

        loadItems()
        
    }
    @IBAction func closeSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func addButton(_ sender: Any) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settingsData.count
        case 1:
            return allergens.count
        default:
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsViewCell
        
        switch indexPath.section {
        case 0:
            cell.label.text = settingsData[indexPath.row]
            break
        case 1:
            cell.label.text = allergens[indexPath.row].name
            cell.isTrue.isOn = allergens[indexPath.row].state
            cell.isTrue.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
            cell.isTrue.tag = indexPath.row
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headers.count {
            return headers[section]
        }

        return nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let tableView = view as? UITableViewHeaderFooterView else { return }
        tableView.textLabel?.textColor = .white
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, competionHandler) in
            if let result = try? self.context.fetch(Settings.fetchRequest()) {
                for _ in result {
                    self.context.delete(self.allergens[indexPath.row])
                }
                self.saveContext()
                self.loadItems()
                self.settingsTable.reloadData() 
            }
        }
        
        action.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    //trailingSwipeActionsConfigurationForRowAtIndexPath:
    
    @objc func switchChangedUD(sender : UISwitch){
        
    }
    
    @objc func switchChanged(sender : UISwitch){
        allergens[sender.tag].state = !allergens[sender.tag].state
        
        saveContext()
    }
    
    func loadItems(with request : NSFetchRequest<Settings> = Settings.fetchRequest() ){
        do{
            allergens = try context.fetch(request)
            
        }
        catch{
            print("Error fetching data from context \(error)")
        }
    }
    
    func saveContext(){
        do{
            try context.save()
        }
        catch{
            print("Error saving context : \(error)")
        }
    }
}

