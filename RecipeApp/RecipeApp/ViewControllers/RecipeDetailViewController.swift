//
//  RecipeDetailViewController.swift
//  RecipeApp
//
//  Created by Nguyen D on 3/7/20.
//  Copyright © 2020 Nguyen D. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController, RecipeAddingDelegate {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var lc_Title_Height: NSLayoutConstraint!
    @IBOutlet weak var lc_ContentView_Height: NSLayoutConstraint!
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tvContent.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblTitle.text = recipe?.title
        imvPhoto.image = Utils.convertBase64ToImage(recipe!.photo)
        tvContent.text = recipe?.content
        
        let size = UIScreen.main.bounds.size
        var height = Utils.getTextHeight(lblTitle.text, font: UIFont.systemFont(ofSize: 20, weight: .semibold), constrainedToWidth: size.width - 40)
        height = height < 25 ? 25 : height
        lc_Title_Height.constant = height
        
        height = Utils.getTextHeight(tvContent.text, font: UIFont.systemFont(ofSize: 17, weight: .regular), constrainedToWidth: size.width - 4)
        height += 20
        
        lc_ContentView_Height.constant = lc_Title_Height.constant + 200 + height
        
        self.containView.layoutIfNeeded()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEdit" {
            let nav = segue.destination as? UINavigationController
            let vc = nav!.topViewController as? RecipeAddingViewController
            vc?.recipe = recipe
            vc?.delegate = self
        }
    }
    
    func didDeleteRecipe() {
        self.navigationController?.popViewController(animated: true)
    }
}
