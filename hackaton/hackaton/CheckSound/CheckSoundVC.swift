//
//  CheckSoundVC.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import UIKit
import LGButton
import Lottie

class CheckSoundVC: UIViewController {
    
    @IBOutlet weak var choiceView: UIView!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var spinView: UIView!
    var spin: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processView.isHidden = true
        setSpin()
    }
    
     func setSpin() {
        spin = .init(name: "girl")
        spin?.frame = spinView.bounds
        spin?.center = spinView.center
        spinView.addSubview(spin!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewDidAppear(true)
        spin?.animationSpeed = 2.5
            spin?.loopMode = .loop
            spin?.play()
        }

        // Allows the animation to disappear from View Controller
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(true)
            spin?.pause()
        }
    
    
    @IBAction func fromFile(_ sender: UIControl) {
        
    }
    
    @IBAction func fromURL(_ sender: UIControl) {
    }
}
