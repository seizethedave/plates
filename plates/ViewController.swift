//
//  ViewController.swift
//  plates
//
//  Created by David Grant on 10/9/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func plateAdded(_ sender: UITextField) {
        print(sender.text!)
        sender.text = ""
    }
    
}

