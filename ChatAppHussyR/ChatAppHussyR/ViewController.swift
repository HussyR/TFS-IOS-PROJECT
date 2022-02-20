//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit

class ViewController: UIViewController {

}

//MARK: Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if LOG
        print(#function)
        #endif
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        #if LOG
        print(#function)
        #endif
    }

}
