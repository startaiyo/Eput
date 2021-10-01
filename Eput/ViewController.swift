import UIKit
import AVFoundation
import RealmSwift

class InputList: Object{
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var createdAt = Date()
    @objc dynamic var content : String = ""
    @objc dynamic var isChecked : Bool = false
    @objc dynamic var tag : String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var InputTableView: UITableView!
    @IBOutlet weak var inputbutton: UIButton!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputScrollView: UIScrollView!
    var token:NotificationToken!
    let realm = try! Realm()
    var inputList:Results<InputList>!
    private var input = [InputList]()
    private var il = [""]
    let label = UILabel()
    let button = UIButton()
    let cellIdentifier = "InputTableViewCell"
    var pickerView: UIPickerView = UIPickerView()
    let langlist: [String] = ["ja-JP","en-US"]
    override func viewDidLoad() {
        
        input = realm.objects(InputList.self).map({$0})
        self.InputTableView.delegate=self
        self.InputTableView.dataSource=self
        self.InputTableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        self.inputList = realm.objects(InputList.self)
        for i in inputList{
            if i.isChecked{
            il.append(i.content)
        }
        }
        il.removeFirst()
        let hoge = il.joined(separator: "、っ、")
        initView(i: hoge)
        token = realm.observe{ notification, realm in
            //変更があった場合にtableViewを更新
            self.InputTableView.reloadData()
            self.inputList = realm.objects(InputList.self)
            self.il = [""]
            for i in self.inputList{
                if i.isChecked{
                    self.il.append(i.content)
            }
            }
            self.il.removeFirst()
            let hoge = self.il.joined(separator: "、っ、")
            self.initView(i: hoge)
            super.viewDidLoad()
        }
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
                
                // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
                
                // インプットビュー設定
        languageField.inputView = pickerView
        languageField.inputAccessoryView = toolbar
        
        pickerView.selectRow(0, inComponent: 0, animated: false)
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
        label.center = CGPoint(x: self.view.center.x, y: 50)
        label.text = i
        label.textColor = UIColor.black
        self.view.addSubview(label)
        button.frame = CGRect(x: 0, y: 300, width: 300, height: 30)
        button.center = CGPoint(x: self.view.center.x, y: 150)
        button.backgroundColor = UIColor.red
        button.titleLabel?.textColor = UIColor.white
        button.setTitle("input読み上げ", for: .normal)
        button.addTarget(self, action: #selector(ViewController.speech), for: .touchUpInside)
        self.view.addSubview(button)
        inputbutton.frame = CGRect(x: 110, y: 100, width: 300, height: 30)
        inputbutton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
        inputField.frame = CGRect(x: 20, y: 180, width: 150, height: 30)
        valid(inputField)
        inputField.addTarget(self, action: #selector(self.valid(_:)), for: UIControl.Event.editingChanged)
        languageField.frame = CGRect(x: self.view.center.x-50, y: 40, width: 100, height: 30)
    }
    @objc func btnSave(_ sender: Any){
        let inputContent = inputField.text
        let newInput = InputList()
        newInput.content = inputContent!
        do{
            try realm.write({ () -> Void in
                            realm.add(newInput)
                            print("ToDo Saved")
            })
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
        print(textField.text!)
        self.inputbutton.isEnabled = true
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.inputList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputTableViewCell",for: indexPath) as! InputTableViewCell
        cell.inputLabel.text = inputList[indexPath.row].content
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.isChecked = inputList[indexPath.row].isChecked
        cell.boolLabel.text = String(inputList[indexPath.row].isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            // Realmのデータ削除
            try! realm.write(withoutNotifying:[token]) {
                realm.delete(inputList[indexPath.row])
            }
            // テーブルのデータ削除
            self.InputTableView.deleteRows(at: [indexPath], with: .automatic)
        self.perform(#selector(reloadTable), with: nil, afterDelay: 0.1)
        self.inputList = realm.objects(InputList.self)
        self.il = [""]
        for i in self.inputList{
            if i.isChecked{
                self.il.append(i.content)
        }
        }
        self.il.removeFirst()
        let hoge = self.il.joined(separator: "、っ、")
        self.initView(i: hoge)
    }
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
            languageField.endEditing(true)
            languageField.text = "\(langlist[pickerView.selectedRow(inComponent: 0)])"
    }
}
class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "check_on")! as UIImage
    let uncheckedImage = UIImage(named: "check_off")! as UIImage
    let realm = try! Realm()
    
    var inputList:Results<InputList>?
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
    }



    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
        print(tag)
        var target = inputList?[tag]
        try! realm.write{
            target?.isChecked = self.isChecked
            realm.add(target!, update:.modified)
        }
    }
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {

   // ドラムロールの列数
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
   // ドラムロールの行数
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return langlist.count
   }
   
   // ドラムロールの各タイトル
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return langlist[row]
   }
}
