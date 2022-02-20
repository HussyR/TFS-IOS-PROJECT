//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit

class ViewController: UIViewController {
    var logging = (UIApplication.shared.delegate as? AppDelegate)?.logging
}

//MARK: Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let logging = logging,
              logging
        else {return}
        print(#function)
    }

}
