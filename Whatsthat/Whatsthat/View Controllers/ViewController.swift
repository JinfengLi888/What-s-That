//
//  ViewController.swift
//  Whatsthat
//
//  Created by Jinfeng on 11/14/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController,
                    UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var passImage:UIImage?
    var cameraPermission = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // check permission every time when view appear, because user could change permisison anytime.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCameraPermission()
    }
    
    // check carmera permission, if use does not allow, popup alert using MBProgressbar
    private func checkCameraPermission() {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
        case .denied:
            print("cameraAuthorizationStatus=denied")
            break
        case .authorized:
            print("cameraAuthorizationStatus=authorized")
            self.cameraPermission = true
            break
        case .restricted:
            print("cameraAuthorizationStatus=restricted")
            break
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        self.cameraPermission = true
                    } else {
                        self.cameraPermission = false
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func checkFavorAction(_ sender: Any) {
        
    }
    
    // allow use to choose photo from album or take photo using camera
    @IBAction func takePhotoAction(_ sender: Any) {
        if !isConnectedToNetwork() {
            showMBWithText(title: "Please check your network connection", view: self.view)
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (alert) in
                imagePicker.sourceType = .camera
            if !self.cameraPermission{
                showMBWithText(title: "Please allow to use your camera!", view: self.view)
                return
            }
            self.present(imagePicker, animated: true) {
                
            }
        }
        let albumAction = UIAlertAction(title: "Choose from album", style: .default) { (alert) in
                imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true) {
                
            }
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive) { (aleert) in
            imagePicker.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerViewController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickerImage = info[UIImagePickerControllerEditedImage] as? UIImage
        passImage = pickerImage
        print(pickerImage ?? "no image found")
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "DescListVCSegue", sender: self)
        }
    }
    
    // prepare image before push to search
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DescListVCSegue"{
            let descVC = segue.destination as? DescListViewController
            descVC?.passedImage = passImage
        }
    }
}

