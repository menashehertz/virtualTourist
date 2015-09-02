//
//  PictureCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit

class PictureCollectionViewController: UIViewController {

    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var msgText = "No Message"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "the pictures"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "⬅︎OK", style: .Plain, target: self, action: "cancelAuth")
        messageLabel.text = msgText
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

