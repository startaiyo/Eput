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
    let utterButton = UIButton()
    let utterLabel = UILabel()
    var utterField = UITextField()
    private var cl = [String]()
    var token:NotificationToken!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTableView.register(UINib(nibName: "TagTableViewCell", bundle: nil), forCellReuseIdentifier: "TagTableViewCell")
        self.contentTableView.dataSource=self
        self.contentTableView.delegate=self
        self.inputList = realm.objects(InputList.self)
        // Do any additional setup after loading the view.
        self.cl = [String]()
        for i in inputList{
            if i.isChecked{
                cl.append(i.content)
            }
        }
        self.contentTableView.reloadData()
        let hoge = cl.joined(separator: "、っ、")
        self.initView(i: hoge)
        token = realm.observe{ notification, realm in
            //変更があった場合にtableViewを更新
            self.contentTableView.reloadData()
            self.inputList = realm.objects(InputList.self)
            self.cl = [String]()
            for i in self.inputList{
                if i.isChecked{
                    self.cl.append(i.content)
            }
            }
            let hoge = self.cl.joined(separator: "、っ、")
            self.initView(i: hoge)
            super.viewDidLoad()
        }
    }
    func initView(i:String){
        print("initview")
        utterLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        utterLabel.center = CGPoint(x: self.view.center.x, y: 50)
        utterLabel.text = i
        utterLabel.textColor = UIColor.black
        self.view.addSubview(utterLabel)
        utterButton.frame = CGRect(x: 0, y: 300, width: 300, height: 30)
        utterButton.center = CGPoint(x: self.view.center.x, y: 150)
        utterButton.backgroundColor = UIColor.red
        utterButton.titleLabel?.textColor = UIColor.white
        utterButton.setTitle("input読み上げ", for: .normal)
        utterButton.addTarget(self, action: #selector(speech), for: .touchUpInside)
        self.view.addSubview(utterButton)
    }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.utterLabel.text!)
        let voice = AVSpeechSynthesisVoice(language: utterField.text)
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
            if i.isChecked{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell",for: indexPath) as! TagTableViewCell
        cell.tagLabel.text = cl[indexPath.row]
        cell.tagCheckBtn.tag = indexPath.row
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
