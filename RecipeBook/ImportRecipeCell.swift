//
//  ImportRecipeCell.swift
//  RecipeBook
//
//  Created by William Farley on 4/24/17.
//  Copyright © 2017 William Farley. All rights reserved.
//

import UIKit

class ImportRecipeCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureImportRecipeCell(title: String, ingredients: String, imageURL: String) {
        
        if imageURL.contains("http://") {
            let imageURL = URL(string: imageURL)
            let data = try? Data(contentsOf: imageURL!)
            recipeImage.image = UIImage(data: data!)
        } else {
            recipeImage.image = UIImage(named: "defaultImage")
        }
        
        titleLabel.text = title
        ingredientsLabel.text = ingredients
        
    }

}
