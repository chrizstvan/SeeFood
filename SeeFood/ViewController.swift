//
//  ViewController.swift
//  SeeFood
//
//  Created by Christian Stevanus on 14/02/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var displayImage: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    //after photo send photo to machine learning
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // this is photo from camera or image that user choose from galery
        if let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            displayImage.image = userPickerImage
            
            guard let ciImage = CIImage(image: userPickerImage) else {
                fatalError("Could not convert UI Image to CI image")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage)  {
        
        guard let myModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML failed")
        }
        
        let request = VNCoreMLRequest(model: myModel) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            print(result)
            if let firstResult = result.first {
                self.navigationItem.title = firstResult.identifier
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
    
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    // Tap to photo
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

