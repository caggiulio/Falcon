//
//  ViewController.swift
//  Falcon
//
//  Created by caggiulio on 11/17/2020.
//  Copyright (c) 2020 caggiulio. All rights reserved.
//

import UIKit
import Falcon

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Falcon.request(url: "todos/1", method: .get) { (response) in
            if response.success {
                if let data = response.data {
                    let todo = try? JSONDecoder().decode(Todo.self, from: data)
                    print(todo)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

