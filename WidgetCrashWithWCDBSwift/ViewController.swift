//
//  ViewController.swift
//  WidgetCrashWithWCDBSwift
//
//  Created by Lei Li on 15/04/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let info = TestInfo()
        info.uuid = UUID().uuidString
        TestManager.manager.saveInfo(info: info)
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Restarted", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }


}

