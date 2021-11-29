//
//  ContentsViewController.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/25.
//

import UIKit
import RealmSwift
import AVFoundation

class ContentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    let realm = try! Realm()
    var inputList:Results<InputList>!
    private var input = [InputList]()
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contentTableViewCell: UITableViewCell!
    var ViewController: UIViewController!
    @IBOutlet weak var languagelabel: UILabel!
    @IBOutlet weak var utterbutton: UIButton!
    @IBOutlet weak var utterlabel: UILabel!
    var utterField = UITextField()
    private var cl = [String]()
    var token:NotificationToken!
    var tag = ""
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.languagelabel.text = "ja-JP"
        self.contentTableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        self.contentTableView.dataSource=self
        self.contentTableView.delegate=self
        self.inputList = realm.objects(InputList.self)
        // Do any additional setup after loading the view.
        self.cl = [String]()
        for i in inputList{
            if i.tag == tag{
                cl.append(i.content)
            }
        }
        self.contentTableView.reloadData()
        let hoge = cl.joined(separator: "、っ、")
        initView(i: hoge)
        token = realm.observe{ notification, realm in
            //変更があった場合にtableViewを更新
            self.contentTableView.reloadData()
            self.inputList = realm.objects(InputList.self)
            self.cl = [String]()
            for i in self.inputList{
                if (i.tag == self.tag) && (i.isChecked){
                    self.cl.append(i.content)
            }
            }
            let hoge = self.cl.joined(separator: "、っ、")
            self.initView(i: hoge)
            super.viewDidLoad()
        }
    }
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.contentTableView.reloadData()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    func initView(i:String){
        utterlabel.text = i
        utterbutton.addTarget(self, action: #selector(speech), for: .touchUpInside)
    }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.utterlabel.text!)
        let voice = AVSpeechSynthesisVoice(language: languagelabel.text)
        utterance.voice = voice
        speechSynthesizer.speak(utterance)
    }
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    override func viewDidAppear(_ animated: Bool) {
        self.cl = [String]()
        for i in inputList{
            if i.tag == tag{
                cl.append(i.content)
            }
        }
        let hoge = cl.joined(separator: "、っ、")
        self.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cl.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputTableViewCell",for: indexPath) as! InputTableViewCell
        cell.inputLabel.text = cl[indexPath.row]
        cell.checkBtn.tag = indexPath.row
        self.view.bringSubviewToFront(self.contentTableView)
//        cell.tagCheckBtn.isChecked = inputList[indexPath.row].isChecked
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
class CustomCell: UITableViewCell {
    var indexPath = IndexPath()

    @IBAction func pushCellButton(_ sender: UIButton) {
        print(indexPath.row)
    }
}
