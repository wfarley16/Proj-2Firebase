//
//  DetailVC.swift
//  RecipeBook
//
//  Created by William Farley on 4/22/17.
//  Copyright © 2017 William Farley. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class DetailVC: UIViewController {
    
    var pickerIndex = 0
    var recipesArray = [Recipes]()
    var ingredientsArray = [String]()
    
    var recipesRef: FIRDatabaseReference!
    
    var userDisplayName = ""
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var recipePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipePicker.delegate = self
        recipePicker.dataSource = self
        
        recipesRef = FIRDatabase.database().reference(withPath: "recipes")
        
        recipesRef.observe(.value, with: { snapshot in
            self.recipesArray = []
            for child in snapshot.children {
                let recipeSnapshot = child as! FIRDataSnapshot
                let newRecipe = Recipes()
                let recipeValue = recipeSnapshot.value as! [String: AnyObject]
                newRecipe.title = recipeValue["title"] as! String
                newRecipe.ingredients = recipeValue["ingredients"] as! String
                newRecipe.imageURL = recipeValue["imageURL"] as! String
                newRecipe.recipeKey = recipeSnapshot.key
                self.recipesArray.append(newRecipe)
            }
            self.recipePicker.reloadAllComponents()
        })
        
        if recipesArray.count == 0 {
            performSegue(withIdentifier: "ToListVC", sender: nil)
        } else {
            refreshUI()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("User has signed in")
            let displayName = FIRAuth.auth()?.currentUser?.displayName
        } else {
            performSegue(withIdentifier: "ToSignIn", sender: nil)
        }
    }
    
    func refreshUI() {
        recipeImage.image = UIImage(named: recipesArray[pickerIndex].imageURL)
        
        if recipesArray[pickerIndex].imageURL.contains("http://") {
            let imageURL = URL(string: recipesArray[pickerIndex].imageURL)
            let data = try? Data(contentsOf: imageURL!)
            recipeImage.image = UIImage(data: data!)
        } else {
            if recipesArray[pickerIndex].imageURL == "defaultImage" {
                recipeImage.image = UIImage(named: recipesArray[pickerIndex].imageURL)
            } else {
                print("Here is where you'd fetch an image from your directory that was stored locally.")
            }
        }
        
        titleLabel.text = recipesArray[pickerIndex].title
        ingredientsLabel.text = recipesArray[pickerIndex].ingredients
        
        print(recipesArray[pickerIndex].href)
        
        if recipesArray[pickerIndex].href == "Not Available" {
            linkButton.isHidden = true
        } else {
            linkButton.isHidden = false
            linkButton.setTitle(recipesArray[pickerIndex].href, for: .normal)
        }
        
        recipePicker.reloadAllComponents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToListVC" {
            let destVC = segue.destination as! UINavigationController
            let targetVC = destVC.topViewController as! ListVC
            targetVC.recipesArray = recipesArray
        }
        
        if segue.identifier == "ToFridgeVC" {
            let destVC = segue.destination as! FridgeVC
            destVC.ingredientsArray = ingredientsArray
        }
        
    }
    
    @IBAction func unwindToDetailVC(sender: UIStoryboardSegue) {
        
        if let userDisplayName = FIRAuth.auth()?.currentUser?.displayName {
            self.userDisplayName = userDisplayName
        } else {
            self.userDisplayName = "Unknown"
        }
        
        if let sourceVC = sender.source as? ListVC {
            recipesArray = sourceVC.recipesArray
        }
        
        if let sourceVC = sender.source as? FridgeVC {
            ingredientsArray = sourceVC.ingredientsArray
        }
        
        refreshUI()
    }

    @IBAction func linkButtonPressed(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: recipesArray[pickerIndex].href)!)
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance().signOut()
        performSegue(withIdentifier: "ToSignIn", sender: nil)
    }
    
}

extension DetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipesArray[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
        refreshUI()
    }
}






