import UIKit
import AVFoundation
import RealmSwift

class InputList: Object{
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var createdAt = Date()
    @objc dynamic var content : String = ""
    @objc dynamic var isChecked : Bool = false
    override static func primaryKey() -> String? {
        return "id"
    }
}
//class NewInputViewController: UIViewController{
//    @IBOutlet weak var txtContent: UITextField!
//    @IBOutlet weak var sendbutton: UIButton!
//    @IBOutlet weak var backbutton: UIButton!
//    private let realm = try! Realm()
//    public var completionHandler: (() -> Void)?
//    override func viewDidLoad() {
//        super .viewDidLoad()
//        sendbutton.frame = CGRect(x: 0, y: 200, width: 300, height: 30)
//        sendbutton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(btnSave))
//        backbutton.frame = CGRect(x: 0, y: 100, width: 300, height: 30)
//        backbutton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
//    }
//    @objc func didTapButton() {
//        self.dismiss(animated: true, completion: nil)
//        }
//    @objc func btnSave(_ sender: Any){
//        let inputContent = txtContent.text
//        let newInput = InputList()
//        newInput.content = inputContent!
//        do{
//            try realm.write({ () -> Void in
//                            realm.add(newInput)
//                            print("ToDo Saved")
//            })
//        }catch{
//            print("Saving Is Failed")
//        }
//    }
//}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var InputTableView: UITableView!
    @IBOutlet weak var inputbutton: UIButton!
    let realm = try! Realm()
    var inputList:Results<InputList>!
    private var input = [InputList]()
    private var il = [""]
    let label = UILabel()
    let button = UIButton()
    let cellIdentifier = "InputTableViewCell"
    override func viewDidLoad() {
        
        input = realm.objects(InputList.self).map({$0})
        self.InputTableView.delegate=self
        self.InputTableView.dataSource=self
        self.InputTableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        self.inputList = realm.objects(InputList.self)
        for i in inputList{
            il.append(i.content)
        }
        il.removeFirst()
        let hoge = il.joined(separator: "、っ、")
        initView(i: hoge)
        self.InputTableView.reloadData()
        super.viewDidLoad()
    }
    @IBOutlet weak var moveInput: UIButton!
//    @IBAction func btnAdd(_ sender: Any){
//        guard let vc = storyboard?.instantiateViewController(identifier: "NewInput")
//                as? NewInputViewController else{
//            return
//        }
//        vc.completionHandler = {
//            [weak self] in
//            self?.refresh()
//        }
//        vc.title = "New Input"
//        vc.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    func refresh(){
//        input = realm.objects(InputList.self).map({$0})
//    }
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
        label.center = CGPoint(x: self.view.center.x, y: self.view.center.y-180)
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
        inputField.frame = CGRect(x: 20, y: 100, width: 150, height: 30)
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
            il.append(inputList[inputList.count-1].content)
            let hoge = il.joined(separator: "、っ、")
            label.text = hoge
        }catch{
            print("Saving Is Failed")
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
        cell.inputLabel.text = inputList[indexPath.row].content
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.isChecked = inputList[indexPath.row].isChecked
        cell.boolLabel.text = String(inputList[indexPath.row].isChecked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            // Realmのデータ削除
            try! realm.write {
                realm.delete(inputList[indexPath.row])
            }
            // テーブルのデータ削除
            self.InputTableView.deleteRows(at: [indexPath], with: .automatic)
        il.remove(at: indexPath.row)
        let hoge = il.joined(separator: "、っ、")
        label.text = hoge
    }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.label.text!)
        let voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.voice = voice
        speechSynthesizer.speak(utterance)
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
        print(inputList)
        var target = inputList?[tag]
        try! realm.write{
            target?.isChecked = self.isChecked
            realm.add(target!, update:.modified)
        }
    }
}
