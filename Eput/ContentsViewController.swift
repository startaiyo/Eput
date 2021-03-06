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
    @IBOutlet weak var utterLabel: UILabel!
    @IBOutlet weak var utterbutton: UIButton!
    @IBOutlet weak var contentLanguageField: UITextField!
    let utterLanglist: [String] = ["ja-JP","en-US"]
    var utterField = UITextField()
    var utterPickerView = UIPickerView()
    private var cl = [String]()
    var token:NotificationToken!
    var tag = ""
    var vController = "cvc"
    var list: List<InputList>!
    let list2 = ItemList()
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        self.contentTableView.dataSource=self
        self.contentTableView.delegate=self
        self.inputList = realm.objects(InputList.self).filter("tag == %@ AND tag != ''", self.tag)
//        self.list = realm.objects(ItemList.self).first?.list
//        self.list2.list.append(objectsIn: inputList)
//        print(self.list)
//        print(self.list2)
        // Do any additional setup after loading the view.
        cl = []
        for i in inputList{
            if i.isCheckedTag{
                cl.append(i.content)
            }
        }
        self.contentTableView.reloadData()
        let hoge = cl.joined(separator: "、っ、")
        initView(i: hoge)
        token = realm.observe{ notification, realm in
            //変更があった場合にtableViewを更新
            self.contentTableView.reloadData()
            self.list = realm.objects(ItemList.self).first?.list
            self.cl = [String]()
            for i in self.inputList{
                if i.isCheckedTag{
                    self.cl.append(i.content)
            }
            }
            let hoge = self.cl.joined(separator: "、っ、")
            self.initView(i: hoge)
            super.viewDidLoad()
        }
        utterPickerView.delegate = self
        utterPickerView.dataSource = self
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        contentLanguageField.inputView = utterPickerView
        contentLanguageField.inputAccessoryView = toolbar
        utterPickerView.selectRow(0, inComponent: 0, animated:false)
        contentLanguageField.text = "ja-JP"
        utterLabel.textColor = UIColor.green
    }
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.contentTableView.reloadData()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    func initView(i:String){
        utterLabel.text = i
        utterLabel.textColor = UIColor.white
        utterbutton.addTarget(self, action: #selector(speech), for: .touchUpInside)
    }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.utterLabel.text!)
        let voice = AVSpeechSynthesisVoice(language: contentLanguageField.text)
        utterance.voice = voice
        speechSynthesizer.speak(utterance)
    }
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    override func viewDidAppear(_ animated: Bool) {
        cl = []
        for i in inputList{
            if i.isCheckedTag{
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
        return self.inputList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputTableViewCell",for: indexPath) as! InputTableViewCell
        cell.inputLabel.text = inputList[indexPath.row].content
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.isChecked = inputList[indexPath.row].isCheckedTag
        cell.checkBtn.inputList = inputList
        cell.checkBtn.vc = self.vController
        self.view.bringSubviewToFront(self.contentTableView)
//        cell.tagCheckBtn.isChecked = inputList[indexPath.row].isChecked
        return cell
    }
    @objc func done() {
        contentLanguageField.endEditing(true)
        contentLanguageField.text = "\(utterLanglist[utterPickerView.selectedRow(inComponent: 0)])"
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
extension ContentsViewController : UIPickerViewDelegate, UIPickerViewDataSource {

   // ドラムロールの列数
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
   // ドラムロールの行数
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return utterLanglist.count
   }
   
   // ドラムロールの各タイトル
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return utterLanglist[row]
   }
}

