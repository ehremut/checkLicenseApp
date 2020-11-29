//
//  SoundVC.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import UIKit
import LGButton

protocol YourCellDelegate : class {
    func didPressButton(_ tag: Int)
}

class SoundVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var music = CheckModel()
    @IBOutlet weak var findAudioView: UIView!{
        didSet {
            findAudioView.layer.cornerRadius = 30
            //findAudioView.backgroundColor = UIColor
        }
    }
    
    @IBOutlet weak var playView: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleTV: UILabel!
    @IBOutlet weak var likeView: UIButton!
    
    
    @IBOutlet weak var name: UILabel! {
        didSet {
            name.text = music.find?.title
        }
    }
    
    @IBOutlet weak var creator: UILabel!{
        didSet {
            creator.text = music.find?.artist
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        titleTV.isHidden = true
        if (music.similar != nil) && music.similar?.count ?? 0 > 0{
            
            tableView.isHidden = false
            titleTV.isHidden = false
            //self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func like(_ sender: UIButton) {
    }
    
    @IBAction func play(_ sender: UIButton) {
        if music.find?.licence == 0 {
            
        }
        else {
            
            guard let url = URL(string: music.find?.link ?? "") else { return }
            UIApplication.shared.open(url)
        }
        
    }
    

}


extension SoundVC:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return music.similar?.count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! SimilarCell
        cell.title?.text = music.similar?[indexPath.row].title ?? ""
        cell.artist?.text = music.similar?[indexPath.row].artist ?? ""
        cell.play?.tag = indexPath.row
        return cell
    }

        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                self.music.similar?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
             }
        }
    

//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }


}

extension SoundVC: YourCellDelegate {
    func didPressButton(_ tag: Int) {
        
    }
    
    
}
