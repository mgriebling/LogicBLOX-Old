//
//  EditTableCell.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 8 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class EditTableCell: UITableViewCell {

    @IBOutlet var cellPic: UIImageView!
    @IBOutlet var cellTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
