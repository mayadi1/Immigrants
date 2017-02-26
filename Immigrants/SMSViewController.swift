//
//  SMSViewController.swift
//  Immigrants
//
//  Created by Mohamed Ayadi on 2/25/17.
//  Copyright © 2017 Mohamed Ayadi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SMSViewController: UIViewController {
    @IBOutlet weak var phoneNumberTextField: UITextField!
    let ref = FIRDatabase.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: false) {
        }
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        SVProgressHUD.showSuccess(withStatus: "Got it!")
        ref.child("phoneNumbers").childByAutoId().setValue(self.phoneNumberTextField.text)
        self.dismiss(animated: false) {
        }
    }

}
