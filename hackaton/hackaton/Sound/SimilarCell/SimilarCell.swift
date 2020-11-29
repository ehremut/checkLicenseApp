//
//  SimilarCell.swift
//  hackaton
//
//  Created by andarbek on 29.11.2020.
//

import UIKit

protocol BtnDelegate : class {
    func isPressed(_ flag: Bool)
}

class SimilarCell: UITableViewCell {

    var cellDelegate: YourCellDelegate?
    
    @IBOutlet weak var cellView: UIView?
    @IBOutlet weak var play: UIButton?
    @IBOutlet weak var like: UIButton?
    @IBOutlet weak var load: UIButton?
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
        guard let flag = cellDelegate?.didPressButton(sender.tag) else  { return }
        if flag {
            play?.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            play?.setImage(UIImage(named: "play"), for: .normal)
        }
        }
    
    @IBAction func loadPressed(_ sender: UIButton) {
            cellDelegate?.didloadButton(sender.tag)
        }
    

    
}
