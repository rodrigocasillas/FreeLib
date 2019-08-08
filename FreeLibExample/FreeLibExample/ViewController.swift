//
//  ViewController.swift
//  FreeLibExample
//
//  Created by Rodrigo Casillas on 8/8/19.
//  Copyright © 2019 Bluelabs. All rights reserved.
//

import UIKit
import FreeLib

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DaLi.activate(daliKey: "", daliSDKToken: "", domainList: [""], sdType: SDType.FULL)
    }


}

