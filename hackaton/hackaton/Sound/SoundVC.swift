//
//  SoundVC.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import UIKit
import LGButton
import FRadioPlayer

protocol YourCellDelegate : class {
    func didPressButton(_ tag: Int) -> Bool
    func didloadButton(_ tag: Int)
    
}

class SoundVC: UIViewController, FRadioPlayerDelegate {
    
    @IBOutlet weak var licenceView: UIView! {
        didSet {
            
            licenceView.layer.cornerRadius = 8
        }
    }
    var playing = false
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        switch state {
        case .urlNotSet:
            print("")
        case .readyToPlay:
            print("")
        case .loading:
            print("")
        case .loadingFinished:
            print("")
        case .error:
            print("")
        }
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        switch state {
        case .playing:
            print("")
        case .paused:
            player.isAutoPlay = false
        case .stopped:
            player.pause()
        }
    }
    

    let player = FRadioPlayer.shared
   
    var music = CheckModel()
    @IBOutlet weak var findAudioView: UIView!{
        didSet {
            findAudioView.layer.cornerRadius = 30
            //findAudioView.backgroundColor = UIColor
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet{
            imageView.layer.cornerRadius = 30
            imageView.image = music.find?.image
            imageView.contentMode = .left
        }
    }
    
    @IBOutlet weak var playView: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleTV: UILabel!
    @IBOutlet weak var likeView: UIButton!
    
    @IBOutlet weak var licence: UILabel!{
        didSet  {
            switch music.find?.licence! {
            
            case 0:
                licence.text = "Лицензия открытая"
                licence.textColor = .green
            case 1:
                licence.text = "Лицензия закрытая"
                licence.textColor = .systemPink
                
            case 2:
                licence.text = "Лицензия не найдена"
                licence.textColor = .yellow
            default:
                licence.text = "Лицензия не найдена"
                licence.textColor = .yellow
            }
    }
    }
    
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
            self.player.delegate = self
            //self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        player.stop()
    }
    
    @IBAction func like(_ sender: UIButton) {
    }
    
    @IBAction func play(_ sender: UIButton) {
        if music.find?.licence == 0 {
            player.radioURL = URL(string: music.find?.link ?? "")
            player.play()
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
        cell.cellDelegate = self
        cell.play?.tag = indexPath.row
        cell.load?.tag = indexPath.row
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
    
    func didloadButton(_ tag: Int) {
       
        guard let url = URL(string: music.similar?[tag].link ?? "") else { return }
        UIApplication.shared.open(url)
        
    }
    
    func didPressButton(_ tag: Int) -> Bool {
        playing = !playing
        print(tag)
        print(playing)
        print(music.similar?[tag].link)
        player.radioURL = URL(string: music.similar?[tag].link ?? "")
        if playing {
            player.isAutoPlay = true
            player.play()
            return true
        } else {
            player.stop()
            return false
        }
        return playing
    }
    
    
}
