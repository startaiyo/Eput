//
//  RootViewController.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/27.
//

import UIKit
import RealmSwift

class RootViewController: UIViewController {
    let realm = try! Realm()
    var tagList:Results<TagList>!
    private var tags = [TagList]()
    var token:NotificationToken!
    let siteInfo:[Dictionary<String,String>] = [
                ["title":"ヤフー！知恵袋","url":"http://chiebukuro.yahoo.co.jp/"],
                ["title":"教えて！goo","url":"http://oshiete.goo.ne.jp/"],
                ["title":"教えて！goo","url":"http://oshiete.goo.ne.jp/"],
                ["title":"教えて！goo","url":"http://oshiete.goo.ne.jp/"]
            ]
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    override func viewDidLoad() {
//        print("rootdidroad")
        self.tagList = realm.objects(TagList.self)
//        var token = realm.observe{ notification, realm in
//            self.tagList = realm.objects(TagList.self)
//            self.viewDidLoad()
//        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let sb = UIStoryboard(name: "Main", bundle: .main)
        var controllerArray : [UIViewController] = []
        var viewController = sb.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.title = "menu1"
        controllerArray.append(viewController)
        for info in tagList {

                    let controller:ContentsViewController = ContentsViewController(nibName: "ContentsViewController", bundle: nil)
            print(info["tag"]!)
            controller.title = info["tag"] as! String
            controller.utterField.text? = viewController.languageField.text!
//            controller.content = site["url"]!

//                    controller.webView = UIWebView(frame : self.view.bounds)
//            controller.webView.delegate = controller as! UIWebViewDelegate
//                    controller.view.addSubview(controller.webView)
//                    let req = URLRequest(url: URL(string:controller.siteUrl!)!)
//                    controller.webView.loadRequest(req)
                    controllerArray.append(controller)
                }
        print(controllerArray)
                // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
                    .scrollMenuBackgroundColor(UIColor.white),
                    .viewBackgroundColor(UIColor.white),
                    .bottomMenuHairlineColor(UIColor.blue),
                    .selectionIndicatorColor(UIColor.red),
                    .menuItemFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
                    .centerMenuItems(true),
                    .menuItemWidthBasedOnTitleTextWidth(true),
                    .menuMargin(30),
                    .selectedMenuItemLabelColor(UIColor.black),
                    .unselectedMenuItemLabelColor(UIColor.gray)
                ]
                // Initialize scroll menu

        let rect = CGRect(origin: CGPoint(x: 0,y :20), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: rect, pageMenuOptions: parameters)

        self.addChild(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        pageMenu!.didMove(toParent: self)
        viewController.rootCallBack = {self.rootCallBack()}
    }
    func rootCallBack(){
        print("rootが呼ばれたよ")
        self.viewDidLoad()
    }
    var pageMenu : CAPSPageMenu?

        // サイト情報
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
