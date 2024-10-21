//
//  ViewController.swift
//  HotDog ML
//
//  Created by Nastya Klyashtorna on 2024-10-20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Couldn't convert image to CIImage")
            }
            detect(image: ciImage)
        }
       
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Couldn't cast prediction to VNClassificationObservation")
            }
            if let res = result.first {
                if res.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationItem.titleView?.tintColor = .red
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.tintColor = .green
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
        
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    


}

