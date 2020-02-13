
/**
 *  @file  CustomTableViewCell.swift
 *  @brief Tableview custom style UIElments decleartion.
 */

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    
    @IBOutlet weak var logsLabel: UILabel!
    
    /* Initialization code */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /* Configure the view for the selected state */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
