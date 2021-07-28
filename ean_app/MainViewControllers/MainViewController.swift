//
//  ViewController.swift
//  ean_app
//
//  Created by Michał Hęćka on 02/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData


class MainViewController: UIViewController {
    
    

    var delegate: CenterViewControllerDelegate?
    
    var session : AVCaptureSession?
    
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var barFrameView : UIView?
    
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var capturePhotoOutput : AVCapturePhotoOutput?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8]
    
    
    var capturedEan = ""
    
    var viewHidden = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            captureSession?.addOutput(capturePhotoOutput!)
            
            
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8]
        } catch{
            print(error)
            return
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = photoPreviewImageView.bounds
        photoPreviewImageView.layer.addSublayer(previewLayer!)
        
        captureSession?.startRunning()
        
        barFrameView = UIView()
         
        if let barFrameView = barFrameView {
            barFrameView.layer.borderColor = UIColor.init(named: "AccentColor")?.cgColor
            barFrameView.layer.borderWidth = 4
            barFrameView.layer.cornerRadius = 3
            barFrameView.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0 )
            view.addSubview(barFrameView)
            view.bringSubviewToFront(barFrameView)
            view.bringSubviewToFront(barText)
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHidden = false
    }
    
    
    var previousBar = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    @IBOutlet weak var barText: UILabel!
    
    @IBAction func menuTapped(_ sender: Any) {
        delegate?.toggleUpPanel()
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        
    }
    
    func takePhoto(){
        guard let capturePhotoOutput = self.capturePhotoOutput else {return}//makin shure capture is still valid
        
        let photoSettings = AVCapturePhotoSettings()//instance of class
        //settings
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)//passing photo setting and delegate implementing extension AVCapturePhotoCaptureDelegate
    }
    
    
    func saveItems(){
        do{
            try context.save()
        }
        catch{
            print("Error saving context : \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showProduct":
            let vc = segue.destination as! ProductViewController
            vc.ean = capturedEan
            break
        default:
            break
        }
    }
    
    
    
}

extension MainViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()!
        
        let capturedImage = UIImage.init(data: imageData, scale: 1.0)//initialise UIImage with image data
        if let image = capturedImage {
            //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)//saving image to photo album
            //prepareToSave(ean: capturedEan, name: capturedEan, image: image)
            performSegue(withIdentifier: "showProduct", sender: self)
        }
    }
}

extension MainViewController : AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            barFrameView?.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0 )
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barObject = previewLayer?.transformedMetadataObject(for: metadataObj)
        
        
        
        if barObject?.bounds != nil{
            let barBoxed = barObject!.bounds
            
            var heightBar : CGFloat
            var widthBar : CGFloat
            
            if barBoxed.width > barBoxed.height {
                heightBar = 40
                widthBar = barBoxed.width
            }
            else{
                heightBar = barBoxed.height
                widthBar = 40
            }
            
            
            UIView.animate(withDuration: 0.2) {
                self.barFrameView?.frame = CGRect(x: barBoxed.origin.x, y: barBoxed.origin.y + 80, width: widthBar, height: heightBar)
            }
            
        }
        
        if metadataObj.stringValue! != previousBar {
            if supportedCodeTypes.contains(metadataObj.type){

                
                previousBar = metadataObj.stringValue!
                
                
                
                if metadataObj.stringValue != nil{
                    barText.text = metadataObj.stringValue!
                    


                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {

                        self.barText.text = "ean13/8"

                    })
                    capturedEan = metadataObj.stringValue!
                    
                    if !viewHidden{
                        takePhoto()
                    }
                }
            }
        }
    }
}


protocol CenterViewControllerDelegate {
  func toggleUpPanel()
  func collapseSidePanels()
}
