//
//  ViewController.swift
//  Example
//
//  Created by Kyle Begeman on 7/10/17.
//  Copyright © 2017 Kyle Begeman. All rights reserved.
//

import UIKit
import InlineTagController

class ViewController: UIViewController, InlineTagControllerDelegate {

    @IBOutlet weak var tagController: InlineTagController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tagController.setConfiguration(CustomConfiguration())
        tagController.tagDelegate = self
        tagController.setPlaceholderText(text: "Enter new tags...")
    }

    func inlineTagController(_ controller: InlineTagController, didFinishEditing text: String) {
        print("Final tag: \(text)")
    }

    func inlineTagController(_ controller: InlineTagController, didChange text: String) {
        print("Text did change: \(text)")
    }

}

class CustomConfiguration: InlineTagConfigurable {
    var backgroundColor: ColorCollection = (view: UIColor.black, edit: UIColor.lightGray, invalid: UIColor.blue, placeholder: UIColor.green)
    var radius: ValueCollection = (view: 4.0, edit: 0.0, invalid: 8.0)

    var cellHeight: Float = 12.0
}
