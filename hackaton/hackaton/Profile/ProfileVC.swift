//
//  ProfileVC.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import UIKit

class ProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginTF: YVTextField!
    @IBOutlet weak var passwordTF: YVTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
//    func setTF(){
//        let tf = YVTextField()
//        tf.frame = CGRect(x: 60, y: 200, width: view.frame.width - 120, height: 40)
//
//        // Setting highlighting functionality
//        tf.isHighlightedOnEdit = true
//        tf.highlightedColor = .white
//
//        // Setting up small placeholder
//        tf.smallPlaceholderColor = .red
//        tf.smallPlaceholderFont = UIFont.systemFont(ofSize: 12)
//        tf.smallPlaceholderText = "Enter your first name"
//        tf.smallPlaceholderPadding = 12
//        tf.smallPlaceholderLeftOffset = 0
//
//        // Settign up separator line
//        tf.separatorIsHidden = false
//        tf.separatorLineViewColor = tf.smallPlaceholderColor
//        tf.separatorLeftPadding = -8
//        tf.separatorRightPadding = -8
//
//
//        // Customize placeholder
//        tf.placeholder = "Login"
//        tf.placeholderColor = .gray
//
//        tf.textColor = .white
//        tf.font = UIFont(name: "HelveticaNeue-Light", size: 17)
//        tf.delegate = self
//
//        view.addSubview(tf)
//    }
//    

}
