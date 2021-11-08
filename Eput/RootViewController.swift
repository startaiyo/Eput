//
//  RootViewController.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/27.
//

import UIKit

class RootViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("root")
        // Do any additional setup after loading the view.
        let sb = UIStoryboard(name: "Main", bundle: .main)
        var controllerArray : [UIViewController] = []
        var viewController = sb.instantiateViewController(withIdentifier: "ViewController")
        controllerArray.append(viewController)
        for site in siteInfo {

                    let controller:ContentsViewController = ContentsViewController(nibName: "ContentsViewController", bundle: nil)

                    controller.title = site["title"]!
                    controller.content = site["url"]!

//                    controller.webView = UIWebView(frame : self.view.bounds)
//            controller.webView.delegate = controller as! UIWebViewDelegate
//                    controller.view.addSubview(controller.webView)
//                    let req = URLRequest(url: URL(string:controller.siteUrl!)!)
//                    controller.webView.loadRequest(req)
                    controllerArray.append(controller)

                }

                // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
                    .scrollMenuBackgroundColor(UIColor.white),
                    .viewBackgroundColor(UIColor.white),
                    .bottomMenuHairlineColor(UIColor.blue),
                    .selectionIndicatorColor(UIColor.red),
                    .menuItemFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
                    .centerMenuItems(true),
                    .menuItemWidthBasedOnTitleTextWidth(true),
                    .menuMargin(16),
                    .selectedMenuItemLabelColor(UIColor.black),
                    .unselectedMenuItemLabelColor(UIColor.gray)

                ]
                // Initialize scroll menu

        let rect = CGRect(origin: CGPoint(x: 0,y :20), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: rect, pageMenuOptions: parameters)

        self.addChild(pageMenu!)
        print("self.viewとは")
        print(self.view)
        print("です")
        print(pageMenu!.view)
        self.view.addSubview(pageMenu!.view)
        pageMenu!.didMove(toParent: self)
    }

    var pageMenu : CAPSPageMenu?

        // サイト情報
    let siteInfo:[Dictionary<String,String>] = [
            ["title":"ヤフー！知恵袋","url":"http://chiebukuro.yahoo.co.jp/"],
            ["title":"教えて！goo","url":"http://oshiete.goo.ne.jp/"],
            ["title":"OKWAVE","url":"http://okwave.jp/"],
            ["title":"発言小町","url":"http://komachi.yomiuri.co.jp/"],
            ["title":"BIGLOBEなんでも相談室","url":"http://soudan.biglobe.ne.jp/sp/"]
        ]
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
