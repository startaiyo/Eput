import UIKit
import AVFoundation
import RealmSwift

class InputList: Object{
    @objc dynamic var content : String = ""
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
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
        let hoge = "ホゲホゲホゲホゲホゲホゲピヨピヨピヨピヨピヨ"
        initView(i: hoge)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{return input.count}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "input",for: indexPath)
        cell.textLabel?.text = input[indexPath.row].content
        return cell
    }
    @IBAction func btnAdd(_ sender: Any){}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

