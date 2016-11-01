//
//  CustomTableViewCell.swift
//  scoop
//
//  Created by Juan Luis Garcia on 29/10/16.
//  Copyright © 2016 styleapps. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var authorCellTxtLbl: UILabel!
    
    @IBOutlet weak var titleCellTxtLbl: UILabel!

    override func awakeFromNib() {
      
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
