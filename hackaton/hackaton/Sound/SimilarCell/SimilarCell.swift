//
//  SimilarCell.swift
//  hackaton
//
//  Created by andarbek on 29.11.2020.
//

import UIKit

class SimilarCell: UITableViewCell {

    var cellDelegate: YourCellDelegate?
    
    @IBOutlet weak var cellView: UIView?
    @IBOutlet weak var play: UIButton?
    @IBOutlet weak var like: UIButton?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var artist: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        cellView?.layer.cornerRadius = 20
        cellView?.layer.masksToBounds = true
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
            cellDelegate?.didPressButton(sender.tag)
        }
    
}
