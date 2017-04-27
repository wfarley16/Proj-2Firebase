//
//  AddVC.swift
//  RecipeBook
//
//  Created by William Farley on 4/23/17.
//  Copyright © 2017 William Farley. All rights reserved.
//

import UIKit

class AddVC: UIViewController {
    
    var recipeToImport = Recipes()
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ingredientsField: UITextField!
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var newEditRecipe: UINavigationItem!
    @IBOutlet weak var addEditPicture: UILabel!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var recipePuppyImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Add VC has loaded. It contains \(recipeToImport.title).")
        
        if recipeToImport.title == "" {
            self.newEditRecipe.title = "New Recipe"
            self.addEditPicture.text = "Set Picture"
            self.nameField.text = ""
            self.ingredientsField.text = ""
            self.recipeImage.image = UIImage(named: "defaultImage")
            self.importButton.isHidden = false
            self.recipePuppyImage.isHidden = false
        } else {
            newEditRecipe.title = "Edit Recipe"
            addEditPicture.text = "Edit Picture"
            
            reloadFields()
            
            importButton.isHidden = true
            recipePuppyImage.isHidden = true
        }
        
    }
    
    func reloadFields() {
        nameField.text = recipeToImport.title
        ingredientsField.text = recipeToImport.ingredients
        
        if recipeToImport.imageURL.contains("http://") {
            let imageURL = URL(string: recipeToImport.imageURL)
            let data = try? Data(contentsOf: imageURL!)
            recipeImage.image = UIImage(data: data!)
        } else {
            recipeImage.image = UIImage(named: recipeToImport.imageURL)
        }
    }
    
    @IBAction func nameFieldEditingChanged(_ sender: UITextField) {
        recipeToImport.title = nameField.text!
    }
    
    @IBAction func ingredientsFieldEditingChanged(_ sender: UITextField) {
        recipeToImport.ingredients = ingredientsField.text!
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
        
    @IBAction func unwindFromImportVC(sender: UIStoryboardSegue) {
        let sourceVC = sender.source as! ImportVC
        
        if sourceVC.recipeToImport.title == "Pending" {
            print("User didn't import a recipe")
        } else {
        
            recipeToImport.title = sourceVC.recipeToImport.title
            recipeToImport.ingredients = sourceVC.recipeToImport.ingredients
            recipeToImport.imageURL = sourceVC.recipeToImport.imageURL
            recipeToImport.href = sourceVC.recipeToImport.href
            
            reloadFields()
            
        }
    }
    
}












