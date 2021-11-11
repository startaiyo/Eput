//
//  ContentsViewController.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/25.
//

import UIKit
import RealmSwift

class ContentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    let realm = try! Realm()
    var inputList:Results<InputList>!
    private var input = [InputList]()
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contentTableViewCell: UITableViewCell!
    
    var content:String!
    var siteUrl:String!
    let cl = ["あああ","いいい","ううう","hoghoe"]
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
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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
