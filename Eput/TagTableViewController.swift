//
//  TagTableViewController.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/21.
//

import UIKit
import RealmSwift
class TagTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var TagTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contentButton: UIButton!
    let realm = try! Realm()
    var tagList:Results<TagList>!
    private var tags = [TagList]()
    var callBack: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TagTableView.delegate=self
        self.TagTableView.dataSource=self
        self.TagTableView.register(UINib(nibName: "TagTableViewCell", bundle: nil), forCellReuseIdentifier: "TagTableViewCell")
        self.tagList = realm.objects(TagList.self)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        contentButton.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tagList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath) as! TagTableViewCell
        cell.tagLabel.text = tagList[indexPath.row].tag
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            // Realmのデータ削除
            try! realm.write() {
                realm.delete(tagList[indexPath.row])
            }
            // テーブルのデータ削除
            self.TagTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true){
            self.callBack?()
        }
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
                            self.TagTableView.reloadData()
                        }catch{
                            print("Saving Is Failed")
                        }
                    }
                }
            )

            self.present(alert, animated: true, completion: nil)
        }
}
