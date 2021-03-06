import UIKit
import AVFoundation
import RealmSwift
import SwiftReorder

class InputList: Object{
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var createdAt = Date()
    @objc dynamic var content : String = ""
    @objc dynamic var isChecked : Bool = false
    @objc dynamic var tag : String = ""
    @objc dynamic var isCheckedTag : Bool = false
//    @objc dynamic var order = 0
    override static func primaryKey() -> String? {
        return "id"
    }
}
class ItemList: Object{
    let list = List<InputList>()
}
class TagList: Object{
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var tag : String = ""
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var InputTableView: UITableView!
    @IBOutlet weak var inputbutton: UIButton!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var inputScrollView: UIScrollView!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var deletetagbutton: UIButton!
    var token:NotificationToken!
    let realm = try! Realm()
    var inputList:Results<InputList>!
    private var input = [InputList]()
    private var il = [""]
    let label = UILabel()
    let button = UIButton()
    let cellIdentifier = "InputTableViewCell"
    var pickerView = UIPickerView()
    var pickerView2 = UIPickerView()
    let langlist: [String] = ["ja-JP","en-US"]
    var tagList:Results<TagList>!
    var taglist=[String]()
    private var tags = [TagList]()
    var rootCallBack: (() -> Void)?
    var pickersw = 0
    var didPrepareMenu = false
    var vController = "vc"
    var list: List<InputList>!
    @IBOutlet weak var editButton: UIButton!
    //    let tabLabelWidth:CGFloat = 100
    
    override func viewDidLoad() {
        input = realm.objects(InputList.self).map({$0})
//        self.InputTableView.reorder.delegate=self
        self.InputTableView.delegate=self
        self.InputTableView.dataSource=self
        self.InputTableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        self.inputList = realm.objects(InputList.self)
        self.list = realm.objects(ItemList.self).first?.list
        for i in list{
            if i.isChecked{
            il.append(i.content)
        }
        }
        self.tagList = realm.objects(TagList.self)
        for i in self.tagList{
            self.taglist.append(i.tag)
        }
        il.removeFirst()
        let hoge = il.joined(separator: "?????????")
        initView(i: hoge)
        token = realm.observe{ notification, realm in
            //???????????????????????????tableView?????????
            self.InputTableView.reloadData()
            self.inputList = realm.objects(InputList.self)
            self.list = realm.objects(ItemList.self).first?.list
            self.taglist = []
            self.il = [""]
            for i in self.list{
                if i.isChecked{
                    self.il.append(i.content)
            }
            }
            self.tagList = realm.objects(TagList.self)
            for i in self.tagList{
                self.taglist.append(i.tag)
            }
            self.il.removeFirst()
            let hoge = self.il.joined(separator: "?????????")
            self.initView(i: hoge)
            super.viewDidLoad()
        }
        
        // ??????????????????
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 1
        pickerView2.delegate = self
        pickerView2.dataSource = self
        pickerView2.tag = 2
                
                // ?????????????????????
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
                // ??????????????????????????????
        languageField.inputView = pickerView
        languageField.inputAccessoryView = toolbar
        tagField.inputView = pickerView2
        tagField.inputAccessoryView = toolbar
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView2.selectRow(0, inComponent: 0, animated: false)
        languageField.text = "ja-JP"
    }
    @IBOutlet weak var moveInput: UIButton!
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        self.InputTableView.reloadData()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initView(i: String){
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        label.center = CGPoint(x: self.view.center.x, y: 100)
        label.text = i
        label.textColor = UIColor.white
        self.view.addSubview(label)
        button.frame = CGRect(x: 0, y: 300, width: 300, height: 30)
        button.center = CGPoint(x: self.view.center.x, y: 150)
        button.backgroundColor = UIColor.red
        button.titleLabel?.textColor = UIColor.white
        button.setTitle("input????????????", for: .normal)
        button.addTarget(self, action: #selector(ViewController.speech), for: .touchUpInside)
        self.view.addSubview(button)
        inputbutton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
        deletetagbutton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        valid(inputField)
        inputField.addTarget(self, action: #selector(self.valid(_:)), for: UIControl.Event.editingChanged)
    }
    @objc func btnSave(_ sender: Any){
        let inputContent = inputField.text
        let inputTag = tagField.text
        let newInput = InputList()
        newInput.content = inputContent!
        newInput.tag = inputTag!
        do{
            try realm.write(){
                if self.list == nil{
                    let itemList = ItemList()
                    itemList.list.append(newInput)
                    self.realm.add(itemList)
                    self.list = self.realm.objects(ItemList.self).first?.list
                }else{
                    self.list.append(newInput)
                }
                realm.add(newInput)
            }
            self.InputTableView.reloadData()
        }catch{
            print("Saving Is Failed")
        }
    }
    @objc func valid(_ textField: UITextField){
        if (textField.text == "") {
            self.inputbutton.isEnabled = false
            return
        }
        self.inputbutton.isEnabled = true
    }
    @IBAction func editTapped(_ sender: Any) {
        if(self.InputTableView.isEditing){
            self.InputTableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: .normal)
        } else {
            self.InputTableView.setEditing(true, animated: true)
            editButton.setTitle("Done", for: .normal)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.inputList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputTableViewCell",for: indexPath) as! InputTableViewCell
        cell.inputLabel.text = list[indexPath.row].content
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.isChecked = list[indexPath.row].isChecked
        cell.checkBtn.vc = self.vController
        cell.checkBtn.t = ""
//        cell.boolLabel.text = String(inputList[indexPath.row].isChecked)
//        cell.deleteBtn.addTarget(self, action: #selector(deleteContent), for: .touchUpInside)
//        cell.deleteBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            // Realm??????????????????
            try! realm.write(withoutNotifying:[token]) {
                realm.delete(list[indexPath.row])
            }
            // ??????????????????????????????
            self.InputTableView.deleteRows(at: [indexPath], with: .automatic)
        self.perform(#selector(reloadTable), with: nil, afterDelay: 0.1)
        self.list = realm.objects(ItemList.self).first?.list
        self.il = [""]
        for i in self.list{
            if i.isChecked{
                self.il.append(i.content)
        }
        }
        self.il.removeFirst()
        let hoge = self.il.joined(separator: "?????????")
        self.initView(i: hoge)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
            try! realm.write {
                let listItem = list[fromIndexPath.row]
                list.remove(at: fromIndexPath.row)
                list.insert(listItem, at: to.row)
            }
        }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell.EditingStyle {
        if InputTableView.isEditing {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
//    @IBAction func deleteContent(_ sender: UIButton){
//        let indexPath = IndexPath(row: sender.tag, section:0)
//        try! realm.write(withoutNotifying:[token]) {
//            let item = list[indexPath.row]
//            realm.delete(item)
//        }
//        // ??????????????????????????????
//        self.InputTableView.deleteRows(at: [indexPath], with: .automatic)
//    self.perform(#selector(reloadTable), with: nil, afterDelay: 0.1)
//    self.inputList = realm.objects(InputList.self)
//    self.il = [""]
//    for i in self.inputList{
//        if i.isChecked{
//            self.il.append(i.content)
//    }
//    }
//    self.il.removeFirst()
//    let hoge = self.il.joined(separator: "?????????")
//    self.initView(i: hoge)
//    }
    @objc func reloadTable() {
        self.InputTableView.reloadData()
    }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.label.text!)
        let voice = AVSpeechSynthesisVoice(language: languageField.text)
        utterance.voice = voice
        speechSynthesizer.speak(utterance)
    }
    @objc func done() {
        if (pickersw == 0){
            languageField.endEditing(true)
            languageField.text = "\(langlist[pickerView.selectedRow(inComponent: 0)])"
        }
        else {
            tagField.endEditing(true)
            tagField.text = "\(taglist[pickerView2.selectedRow(inComponent: 0)])"
        }
    }
    
    @IBAction func goNext(_ sender: Any) {
            // ???storyboard???????????????????????????
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
     
            // ????????????ViewController???????????????????????????
        let nextView = storyboard.instantiateViewController(withIdentifier: "TagTagleViewController") as! TagTableViewController
        nextView.callBack = {self.callBack()}
            // ???????????????
            self.present(nextView, animated: true, completion: nil)
        }
    func callBack(){
        self.rootCallBack?()
    }
}
class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "check_on")! as UIImage
    let uncheckedImage = UIImage(named: "check_off")! as UIImage
    let realm = try! Realm()
    var vc:String!
    var inputList:Results<InputList>?
    var list: List<InputList>!
    var t:String!
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
        self.inputList = realm.objects(InputList.self)
        self.list = realm.objects(ItemList.self).first?.list
    }



    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
        var target = list?[tag]
        if self.vc == "cvc"{
            target = inputList?[tag]
        }
        print(target)
        try! realm.write{
            if self.vc == "vc"{
                target?.isChecked = self.isChecked
            }else if self.vc == "cvc"{
                target?.isCheckedTag = self.isChecked
            }
            realm.add(target!, update:.modified)
        }
    }
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {

   // ???????????????????????????
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
   // ???????????????????????????
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       if (pickerView.tag == 1){
           return langlist.count
       }else{
           return taglist.count
       }
   }
   
   // ????????????????????????????????????
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if (pickerView.tag == 1){
           pickersw = 0
           return langlist[row]
       }else{
           pickersw = 1
           return taglist[row]
       }
   }
}
