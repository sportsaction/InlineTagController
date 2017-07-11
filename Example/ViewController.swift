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

        tagController.tagDelegate = self
        tagController.setPlaceholderText(text: "Enter new tags...")

        InlineTagControllerConfiguration.itemValidation = InlineTagControllerValidation.testEmailAddress |>> InlineTagControllerValidation.testEmptiness
        InlineTagControllerConfiguration.numberOfTags = .quantity(5) // .unlimited also available
    }

    func inlineTagController(_ controller: InlineTagController, didFinishEditing text: String) {
        print("Final tag: \(text)")
    }

    func inlineTagController(_ controller: InlineTagController, didChange text: String) {
        print("Text did change: \(text)")
    }

}

