//
//  ListVC.swift
//  RecipeBook
//
//  Created by William Farley on 4/22/17.
//  Copyright © 2017 William Farley. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recipesArray = [Recipes]()
    var index = -1
    
    var recipesRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("List VC Loaded. recipesArray.count = \(recipesArray.count)")
        
        if recipesArray.count == 0 {
            performSegue(withIdentifier: "ToAdd", sender: nil)
        } else {
            for i in recipesArray {
                print(i)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToEdit" {
            let targetVC = segue.destination as! AddVC
            let selectedRow = tableView.indexPathForSelectedRow!
            targetVC.recipeToImport = recipesArray[selectedRow.row]
        }
        
        if segue.identifier == "ToAdd" {
            
            if let selectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedRow, animated: true)
            }
            
            let destVC = segue.destination as! UINavigationController
            let targetVC = destVC.topViewController as! AddVC
            targetVC.recipeToImport = Recipes()
            targetVC.recipeToImport.title = ""
        }
        
    }
    
    @IBAction func unwindFromAddVC(sender: UIStoryboardSegue) {
        let sourceVC = sender.source as! AddVC
        
        recipesRef = FIRDatabase.database().reference(withPath: "recipes")
    
        let newRecipe = Recipes()
        newRecipe.title = sourceVC.recipeToImport.title
        newRecipe.ingredients = sourceVC.recipeToImport.ingredients
        newRecipe.imageURL = sourceVC.recipeToImport.imageURL
        newRecipe.href = sourceVC.recipeToImport.href
        newRecipe.recipeKey = sourceVC.recipeToImport.recipeKey
        
        if newRecipe.imageURL.characters.count == 0 {
            newRecipe.imageURL = "defaultImage"
        }
        
        if newRecipe.href.characters.count == 0 {
            newRecipe.href = "Not Available"
        }
        
        if let selectedRow = tableView.indexPathForSelectedRow {
            recipesArray[selectedRow.row] = newRecipe
            self.recipesRef.child(recipesArray[selectedRow.row].recipeKey).setValue(["title": newRecipe.title, "ingredients": newRecipe.ingredients, "imageURL": newRecipe.imageURL, "href": newRecipe.href, "recipeKey": newRecipe.recipeKey])
            tableView.deselectRow(at: selectedRow, animated: true)
        } else {
            recipesArray.append(newRecipe)
            let recipeID = self.recipesRef.childByAutoId()
            recipeID.setValue(["title": newRecipe.title, "ingredients": newRecipe.ingredients, "imageURL": newRecipe.imageURL, "href": newRecipe.href])
        }
        
        tableView.reloadData()
    }

}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecipeCell
        cell.configureRecipeCell(title: recipesArray[indexPath.row].title, ingredients: recipesArray[indexPath.row].ingredients, imageURL: recipesArray[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.recipesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.recipesRef.child(recipesArray[indexPath.row].recipeKey).removeValue()
        }
    }
    
}
