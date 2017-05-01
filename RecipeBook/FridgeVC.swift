//
//  FridgeVC.swift
//  RecipeBook
//
//  Created by William Farley on 4/26/17.
//  Copyright © 2017 William Farley. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class FridgeVC: UIViewController {
    
    struct ingredientCell {
        var ingredient: String
        var postedBy: String
        var ingredientKey: String
    }
    
    var ingredientsArray = [ingredientCell]()
    var ingredientsRef: FIRDatabaseReference!
    var user = ""

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = FIRAuth.auth()!.currentUser!.displayName!
        
        self.ingredientsRef = FIRDatabase.database().reference(withPath: "ingredients")
        
        self.ingredientsRef.observe(.value, with: { snapshot in
            self.ingredientsArray = []
            for child in snapshot.children {
                let ingredientSnapshot = child as! FIRDataSnapshot
                let ingredientValue = ingredientSnapshot.value as! [String: AnyObject]
                let ingredientKey = ingredientSnapshot.key
                let newIngredient = ingredientCell(ingredient: ingredientValue["ingredient"] as! String, postedBy: self.user, ingredientKey: ingredientKey)
                self.ingredientsArray.append(newIngredient)
            }
        })
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            editButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            editButton.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func addIngredient(_ sender: UIButton) {
        if let ingredient = textField.text {
            let index = ingredientsArray.count
            ingredientsRef = FIRDatabase.database().reference(withPath: "ingredients")
            let ingredientKey = self.ingredientsRef.childByAutoId().key
            
            ingredientsArray.append(ingredientCell(ingredient: ingredient, postedBy: user, ingredientKey: ingredientKey))
            
            ingredientsRef = FIRDatabase.database().reference(withPath: "ingredients")
            
            self.ingredientsRef.child(ingredientsArray[index].ingredientKey).setValue(["ingredient": ingredientsArray[index].ingredient, "postedBy": ingredientsArray[index].postedBy])
            
            tableView.reloadData()
            textField.text = ""
        }
    }

}

extension FridgeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = ingredientsArray[indexPath.row].ingredient
        cell.detailTextLabel?.text = ingredientsArray[indexPath.row].postedBy
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            ingredientsRef = FIRDatabase.database().reference(withPath: "ingredients")
            ingredientsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.ingredientsRef.child(ingredientsArray[indexPath.row].ingredientKey).removeValue()
            tableView.reloadData()
        }
        
    }
    
}
