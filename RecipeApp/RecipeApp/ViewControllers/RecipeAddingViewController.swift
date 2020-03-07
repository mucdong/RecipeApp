//
//  RecipeAddingViewController.swift
//  RecipeApp
//
//  Created by Nguyen D on 3/7/20.
//  Copyright © 2020 Nguyen D. All rights reserved.
//

import UIKit
import CropViewController

class RecipeAddingViewController: UIViewController {
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var lc_Delete_Height: NSLayoutConstraint!
    
    var delegate: RecipeAddingDelegate?
    var recipeType: Int = 0
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if recipe == nil {
            recipe = Recipe()
            recipe?.id = 0
            recipe?.type = recipeType
            lc_Delete_Height.constant = 0
        }
        
        imvPhoto.image = Utils.convertBase64ToImage(recipe!.photo)
        tfTitle.text = recipe?.title
        tvContent.text = recipe?.content
        tvContent.layer.borderWidth = 1
    }

    // MARK: - Button's actions
    
    @IBAction func onPhotoTapped(_ sender: Any) {
        showPhotoPicker()
    }
    
    func showPhotoPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onDeleteTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (UIAlertAction) in
            self.deleteRecipe()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        if self.isValidData() {
            recipe?.photo = Utils.convertImageToBase64(imvPhoto.image!)
            recipe?.title = tfTitle.text!
            recipe?.content = tvContent.text
            
            DBUtils.shared.saveRecipe(recipe!)
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    func deleteRecipe() {
        DBUtils.shared.deleteRecipe(id: recipe!.id)
        self.dismiss(animated: true) {
            if self.delegate != nil {
                self.delegate?.didDeleteRecipe()
            }
        }
    }
    
    func isValidData() -> Bool {
        if imvPhoto.image == nil {
            let alert = UIAlertController(title: nil, message: "Please select Recipe Photo", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        if tfTitle.text == nil || Utils.trim(tfTitle.text!).isEmpty {
            let alert = UIAlertController(title: nil, message: "Please input Recipe Title", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        if tvContent.text == nil || Utils.trim(tvContent.text!).isEmpty {
            let alert = UIAlertController(title: nil, message: "Please input Recipe Content", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}


// MARK: - UIImagePicker Delegate
extension RecipeAddingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: {
            self.presentCropViewController(image: image!)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Show cropping screen
    func presentCropViewController(image : UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.cancelButtonTitle = "Back"
        cropViewController.doneButtonTitle = "Crop"
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        imvPhoto.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion:{()->Void in
            self.showPhotoPicker()
        })
    }
}

protocol RecipeAddingDelegate: class {
    func didDeleteRecipe()
}
