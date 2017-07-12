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
    }

    func inlineTagController(_ controller: InlineTagController, didFinishEditing text: String) {
        print("Final tag: \(text)")
    }

    func inlineTagController(_ controller: InlineTagController, didChange text: String) {
        print("Text did change: \(text)")
    }

}

class CustomConfiguration: InlineTagConfigurable {
    var backgroundColor: ColorCollection = (view: UIColor.black, edit: UIColor.white, invalid: UIColor.blue, placeholder: UIColor.green)
    var radius: ValueCollection = (view: 10.0, edit: 10.0, invalid: 10.0)


    var font: FontCollection {
        let tagFont = UIFont.systemFont(ofSize: 14.0)
        return (view: tagFont, edit: tagFont, invalid: tagFont, placeholder: tagFont)
    }
    
    var cellHeight: Float = 20.0
    var inset: UIEdgeInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)

    // Note: Any properties of 'InlineTagConfigurable' not implemented will use default values provided by the framework.
}
