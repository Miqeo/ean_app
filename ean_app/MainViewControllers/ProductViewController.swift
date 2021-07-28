//
//  ProductViewController.swift
//  ean_app
//
//  Created by Michał Hęćka on 03/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreData

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    var ean = ""
    var productJSON : JSON = ""
    var productArray = ["name" : String(), "imageUrl" : String(), "quantity" : String(), "serving_size" : String(), "manufacturing_places" : String()]
    var ingredientsArray = [String]()
    var alergentsArray = [String]()
    var allergensBase = [Settings]()
    
    
    
    
    var informationArray = [["quantity","quantity"],["serving size","serving_size"],["manufacturer","manufacturing_places"]]
    
    let headers = ["Overall","Allergens","Ingredients"]
    
    var allergenTurnedOn = false
    var isAnyAllergen = false
    
    let loadingLauncher = LoadingLauncher()
    
    let settingsBase = SettingsBase()
    let productBase = ProductBase()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var productBackground: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var addToFavourites_outlet: UIBarButtonItem!
    
    @IBAction func addToFavourites(_ sender: Any) {
        
        productBase.prepareToSaveItem(ean: ean, name: productArray["name"]!, image: productImage.image ?? UIImage.init(named: "noPhoto")!)
        productBase.saveContext()
        checkIfProductIsSaved(savedItemEan: ean)
    }
    
    @IBAction func backToCam(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareProd(_ sender: Any) {
        shareProduct(text: productArray["name"] ?? "", image: productImage.image!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        productTable.delegate = self
        productTable.dataSource = self
        
        productTable.register(UINib(nibName: "TitleAndImageViewCell", bundle: nil), forCellReuseIdentifier: "TitleAndImageViewCell")
        productTable.register(UINib(nibName: "LongListViewCell", bundle: nil), forCellReuseIdentifier: "ListWithButton")
        
        print(ean)
        loadingLauncher.showLoading()
        allergensBase = settingsBase.loadContext()
        
        getProduct(url: "https://world.openfoodfacts.org/api/v0/product/\(ean).json")
        
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            var count = 0
            for prod in informationArray{
                count = productArray[prod[1]] != "" ? count + 1 : count
            }
            return count
        case 1:
            return alergentsArray.count
        case 2:
            return ingredientsArray.count
        default:
            return 0
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 1{
            
            let cellButton = tableView.dequeueReusableCell(withIdentifier: "ListWithButton", for: indexPath) as! LongListViewCell
            
            cellButton.selectProduct.addTarget(self, action: #selector(addAllergen(sender: )), for: .touchUpInside)
            cellButton.selectProduct.tag = indexPath.row
            cellButton.selectProduct.isHidden = isAllergenAdded(name: alergentsArray[indexPath.row])
            
            cellButton.valueBack.borderColor = allergenTurnedOn == true ? UIColor.systemRed : UIColor.clear
            
            allergenTurnedOn = false
            
            cellButton.valueOfProduct.text = alergentsArray[indexPath.row]
            
            return cellButton
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleAndImageViewCell", for: indexPath) as! TitleAndImageViewCell
            
            switch indexPath.section {
            case 0:
                cell.titleOfProduct.text = informationArray[indexPath.row][0]
                cell.valueOfProduct.text = productArray[informationArray[indexPath.row][1]]
                break
            case 1:
                break
            case 2:
                cell.titleOfProduct.text = ""
                cell.valueOfProduct.text = ingredientsArray[indexPath.row]
                break
            default:
                cell.titleOfProduct.text = ""
                cell.valueOfProduct.text = ""
                break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headers.count {
            return headers[section]
        }

        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let tableView = view as? UITableViewHeaderFooterView else { return }
        tableView.textLabel?.textColor = .white
    }
    
    func shareProduct(text : String, image : UIImage){
        let sharedText = text
        let shared = [sharedText, image] as [Any]
        let activityVC = UIActivityViewController(activityItems: shared, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func getProduct (url : String){
        var result : JSON = ""
        Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding(destination: .queryString)).responseJSON { (response) in
            if response.result.isSuccess {
                //print(JSON(response.result.value!))
                result = JSON(response.result.value!)
                self.setupView(result: result)
                //self.productTable.reloadData()
                self.loadingLauncher.removeLoading()
                
            }
            else if response.result.isFailure{
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: String, imageView : UIImageView) {
        print("Download Started")
        guard let urlType = URL(string: url) else { return }
        getData(from: urlType) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? urlType.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    @objc func addAllergen(sender : UIButton){
        print("Tapped add! \(alergentsArray[sender.tag])")
        
        if alergentsArray[sender.tag] != ""{
            settingsBase.prepareToSaveAllergen(name: alergentsArray[sender.tag])
            settingsBase.saveContext()
            allergensBase = settingsBase.loadContext()
            productTable.reloadData()
        }
    }
    
    func isAllergenAdded(name : String) -> Bool{
        
        var allergenExists = false
        
        for i in allergensBase{
            if i.name == name{
                allergenExists = true
                if i.state == true{
                    allergenTurnedOn = true
                    break
                }
                break
            }
        }
        
        return allergenExists
    }
    
    func displayWarning(allergents : [String], savedAllergents : [Settings]){
    
    
    
        var should = false
        for i in allergents{
            for a in savedAllergents{
                if a.name == i && a.state == true{
                    should = true
                }
            }
    
        }
    
        if should{
            UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction, animations: {
                self.productBackground.backgroundColor = UIColor.red
            }) { (true) in
                UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction, animations: {
                    self.productBackground.backgroundColor = UIColor.init(named: "AccentColor")
                }, completion: nil)
                
            }
            
        }
    }
    
    func checkIfProductIsSaved(savedItemEan : String){
        
        let items = productBase.loadContext()
        
        for i in items{
            if i.ean == savedItemEan{
                addToFavourites_outlet.isEnabled = false
                addToFavourites_outlet.tintColor = UIColor.lightGray
                break
            }
        }
    }

    
    
    func removeOccurences(unprocessedArray : Array<String>) -> Array<String>{
        var i = 0
        var arr = unprocessedArray
        for ing in arr{
            var toChange = ing
            let unwantedChars = ["en:","pl:","_","es:","fr:"]
            for char in unwantedChars{
                toChange = toChange.replacingOccurrences(of: char, with: "")
            }
            
            arr[i] = toChange
            i += 1
        }
        return arr
    }
    
    func setupView(result : JSON){
        productArray["imageUrl"] = result["product"]["image_front_url"].stringValue
        productArray["name"] = result["product"]["product_name"].stringValue
        productArray["quantity"] = result["product"]["quantity"].stringValue
        productArray["serving_size"] = result["product"]["serving_size"].stringValue
        productArray["manufacturing_places"] = result["product"]["manufacturing_places"].stringValue
        
        ingredientsArray = removeOccurences(unprocessedArray: result["product"]["ingredients_hierarchy"].arrayObject as? [String] ?? [])
        alergentsArray = removeOccurences(unprocessedArray: result["product"]["allergens_tags"].arrayObject as? [String] ?? [])
        
        if productArray["name"] != "" || productArray["serving_size"] != "" || productArray["imageUrl"] != ""{
            productName.text = productArray["name"]
            downloadImage(from: productArray["imageUrl"]!, imageView: productImage)
            
            productTable.reloadData()
            checkIfProductIsSaved(savedItemEan: ean)
            
            displayWarning(allergents: alergentsArray, savedAllergents: allergensBase)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    

}
