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
    var tagList:Results<TagList>!
    private var tags = [TagList]()
    @IBOutlet weak var contentbutton: UIButton!
    
    var didPrepareMenu = false
    let tabLabelWidth:CGFloat = 100
    
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
//        inputbutton.frame = CGRect(x: 110, y: 100, width: 300, height: 30)
        inputbutton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
        contentbutton.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)
        valid(inputField)
        inputField.addTarget(self, action: #selector(self.valid(_:)), for: UIControl.Event.editingChanged)
//        languageField.frame = CGRect(x: self.view.center.x-50, y: 40, width: 100, height: 30)
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
    //viewDidLoad等で処理を行うと
    //scrollViewの正しいサイズが取得出来ません
    override func viewDidLayoutSubviews() {

        //viewDidLayoutSubviewsはviewDidLoadと違い
        //何度も呼ばれてしまうメソッドなので
        //一度だけメニュー作成を行うようにします
        if didPrepareMenu { return }
        didPrepareMenu = true

        //scrollViewのDelegateを指定
        inputScrollView.delegate = self

        //タブのタイトル
        var titles = [String]()
        
        for i in realm.objects(TagList.self) {
            titles.append(i.tag)
        }

        //タブの縦幅(UIScrollViewと一緒にします)
        let tabLabelHeight:CGFloat = inputScrollView.frame.height

        //右端にダミーのUILabelを置くことで
        //一番右のタブもセンターに持ってくることが出来ます
        let dummyLabelWidth = inputScrollView.frame.size.width/2 - tabLabelWidth/2
        let headDummyLabel = UILabel()
        headDummyLabel.frame = CGRect(x:0, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        inputScrollView.addSubview(headDummyLabel)

        //タブのx座標．
        //ダミーLabel分，はじめからずらしてあげましょう．
        var originX:CGFloat = dummyLabelWidth
        //titlesで定義したタブを1つずつ用意していく
        for title in titles {
            //タブになるUILabelを作る
            let label = UILabel()
            label.textAlignment = .center
            label.frame = CGRect(x:originX, y:0, width:tabLabelWidth, height:tabLabelHeight)
            label.text = title

            //scrollViewにぺたっとする
            inputScrollView.addSubview(label)

            //次のタブのx座標を用意する
            originX += tabLabelWidth
        }

        //左端にダミーのUILabelを置くことで
        //一番左のタブもセンターに持ってくることが出来ます
        let tailLabel = UILabel()
        tailLabel.frame = CGRect(x:originX, y:0, width:dummyLabelWidth, height:tabLabelHeight)
        inputScrollView.addSubview(tailLabel)

        //ダミーLabel分を足して上げましょう
        originX += dummyLabelWidth

        //scrollViewのcontentSizeを，タブ全体のサイズに合わせてあげる(ここ重要！)
        //最終的なoriginX = タブ全体の横幅 になります
        inputScrollView.contentSize = CGSize(width:originX, height:tabLabelHeight)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.inputScrollView else { return }

        //微妙なスクロール位置でスクロールをやめた場合に
        //ちょうどいいタブをセンターに持ってくるためのアニメーションです

        //現在のスクロールの位置(scrollView.contentOffset.x)から
        //どこのタブを表示させたいか計算します
        let index = Int((scrollView.contentOffset.x + tabLabelWidth/2) / tabLabelWidth)
        let x = index * 100
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
        })
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.inputScrollView else { return }

        //これも上と同様に

        let index = Int((scrollView.contentOffset.x + tabLabelWidth/2) / tabLabelWidth)
        let x = index * 100
        UIView.animate(withDuration: 1.0, animations: {
            scrollView.contentOffset = CGPoint(x:x, y:0)
        })
    }
    @IBAction func enterTapped(_ sender: Any) {
            var alertTextField: UITextField?

            let alert = UIAlertController(
                title: "Edit Name",
                message: "Enter new name",
                preferredStyle: UIAlertController.Style.alert)
            alert.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    alertTextField = textField
                    print(self.tags)
                    // textField.placeholder = "Mike"
                    // textField.isSecureTextEntry = true
            })
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default) { _ in
                    if let text = alertTextField?.text {
                        let tagContent = alertTextField?.text
                        let newTag = TagList()
                        newTag.tag = tagContent!
                        do{
                            try self.realm.write({ () -> Void in
                                self.realm.add(newTag)
                                print(self.realm.objects(TagList.self))
                                print("NewTag Saved")
                            })
                            self.InputTableView.reloadData()
                        }catch{
                            print("Saving Is Failed")
                        }
                    }
                }
            )

            self.present(alert, animated: true, completion: nil)
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
