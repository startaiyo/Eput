import UIKit
import AVFoundation
import RealmSwift

class InputList: Object{
    @objc dynamic var content : String = ""
}
class NewInputViewController: UIViewController{
    @IBOutlet weak var txtContent: UITextField!
    @IBOutlet weak var sendbutton: UIButton!
    @IBOutlet weak var backbutton: UIButton!
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    override func viewDidLoad() {
        super .viewDidLoad()
        sendbutton.frame = CGRect(x: 0, y: 200, width: 300, height: 30)
        sendbutton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(btnSave))
        backbutton.frame = CGRect(x: 0, y: 100, width: 300, height: 30)
        backbutton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    @objc func didTapButton() {
        self.dismiss(animated: true, completion: nil)
        }
    @objc func btnSave(_ sender: Any){
        let inputContent = txtContent.text
        let newInput = InputList()
        newInput.content = inputContent!
        do{
            try realm.write({ () -> Void in
                            realm.add(newInput)
                            print("ToDo Saved")
            })
        }catch{
            print("Saving Is Failed")
        }
    }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputbutton: UIButton!
    private let realm = try! Realm()
    private var input = [InputList]()
    let label = UILabel()
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        let url: URL = URL(string: "https://fw79fhpu20.execute-api.ap-northeast-1.amazonaws.com/default/cssappfunc/cssdetail/1")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            print("data: \(String(describing: data))")
            print("response: \(String(describing: response))")
            print("error: \(String(describing: error))")
        })
        task.resume() //実行する

        input = realm.objects(InputList.self).map({$0})
        print(input)
        let hoge = "ほげホゲホゲホゲホゲホゲホゲピヨピヨピヨピヨピヨ"
        initView(i: hoge)
    }
    @IBOutlet weak var moveInput: UIButton!
    @IBAction func btnAdd(_ sender: Any){
        guard let vc = storyboard?.instantiateViewController(identifier: "NewInput")
                as? NewInputViewController else{
            return
        }
        vc.completionHandler = {
            [weak self] in
            self?.refresh()
        }
        vc.title = "New Input"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func refresh(){
        input = realm.objects(InputList.self).map({$0})
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{return input.count}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "input",for: indexPath)
        cell.textLabel?.text = input[indexPath.row].content
        return cell
    }
    func initView(i: String){
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        label.center = self.view.center
        label.text = i
        self.view.addSubview(label)

        button.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        button.center = CGPoint(x: self.view.center.x, y: self.view.center.y+30)
        button.backgroundColor = UIColor.red
        button.titleLabel?.textColor = UIColor.white
        button.setTitle("テキスト読み上げ", for: .normal)
        button.addTarget(self, action: #selector(ViewController.speech), for: .touchUpInside)
        self.view.addSubview(button)
        inputbutton.frame = CGRect(x: 0, y: 100, width: 300, height: 30)
        inputbutton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    @objc func didTapButton() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewInput") as! NewInputViewController
        self.present(vc, animated: true, completion: nil)

        }
    @objc func speech(){
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: self.label.text!)
        let voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.voice = voice
        speechSynthesizer.speak(utterance)
    }
    override func viewWillAppear(_ animated: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
}

