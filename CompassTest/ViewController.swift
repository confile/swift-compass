//
//  ViewController.swift
//  CompassTest
//
//  Created by Michael Gorski on 21.07.15.
//  Copyright (c) 2015 Majestella. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  override func viewDidAppear(animated: Bool) {
    
    let vc = Page1ViewController()
    self.presentViewController(vc, animated: true, completion: nil)
  }

}

