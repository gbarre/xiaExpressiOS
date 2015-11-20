//
//  ViewDetailInfo.swift
//  xia4ipad
//
//  Created by Guillaume on 18/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewDetailInfo: UIViewController {

    @IBOutlet weak var btnZoom: UISwitch!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBAction func btnCancel(sender: AnyObject) {
        print("Cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
