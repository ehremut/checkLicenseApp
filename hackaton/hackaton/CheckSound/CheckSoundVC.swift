//
//  CheckSoundVC.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import UIKit
import LGButton
import Lottie
import MobileCoreServices
import Alamofire

class CheckSoundVC: UIViewController {
    
    @IBOutlet weak var choiceView: UIView!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var spinView: UIView!
    var spin: AnimationView?
    let module = CheckModule()
    var isLoading = false
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processView.isHidden = true
        self.tabBarController?.tabBar.tintColor = .systemPink
        
        setSpin()
    }
    
     func setSpin() {
        spin = .init(name: "girl")
        spin?.frame = spinView.bounds
        spin?.center = spinView.center
        spinView.addSubview(spin!)
        spin?.animationSpeed = 2.5
        spin?.loopMode = .loop
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewDidAppear(true)
        checkStatus()
        }

        // Allows the animation to disappear from View Controller
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(true)
            checkStatus()
        }
    
    
    @IBAction func fromFile(_ sender: UIControl) {
        //isLoading = true
        docPicker()
    }
    
    @IBAction func fromURL(_ sender: UIControl) {
    }
    
    func checkStatus(){
        isLoaded ? stop() : start()
        isLoading ? start() : stop()
        choiceView.isHidden = isLoading
        processView.isHidden = !isLoading
    }
    
}


extension CheckSoundVC: UIDocumentPickerDelegate {
    
    func start() {
        spin?.play()
    }
    
    func stop() {
        spin?.pause()
    }
    
    func docPicker(){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.movie", "public.audiovisual-content", "public.video", "public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        isLoading = true
        isLoaded = false
        checkStatus()
        
        let imageDataFromURL = try? Data(contentsOf: url)
        let filename = url.absoluteString
        guard let sound = imageDataFromURL?.base64EncodedString() else { return }

        
        Constant.parametersCheck = [
            "Filename" : filename,
            "Sound" : sound
        ]
        
        
        module.check().done { [weak self] (flag) in
            self?.isLoading = false
            self?.isLoaded = true
            self?.checkStatus()
            
            var errMess = ""
            switch flag.code{
            case .access:
                    
                let storyBoard : UIStoryboard = UIStoryboard(name: "Sound", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SoundVC") as! SoundVC
                nextViewController.music = flag.music ?? CheckModel()
                self?.navigationController?.pushViewController(nextViewController, animated: true)
                
               // self?.present(nextViewController, animated:true, completion:nil)
            print("GOOD")
            case .error:
                
                switch flag.error {
                case .wrongPassword:
                    errMess = "Неправильный логин или пароль"
                case .notRegistered:
                    errMess = "Пользователь не зарегистрирован"
                case .unknown:
                    errMess = "Произошла ошибка, повторите снова"
                default:
                    errMess = "Произошла ошибка, повторите снова"
                }
                let alert = UIAlertController(title: "Ошибка", message: errMess, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                
            case .none:
                let alert = UIAlertController(title: "Ошибка", message: errMess, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
            }
            //сделать кнопку активной
        }

      
        
        
    }
    
        
    }
     

