//
//  ConversationViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 07.03.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    
    let model = [
        "My first message hehehe, how is it",
        "There are five types of schools in the US educational system",
        "They are: kindergarten, elementary school, middle school, high school and private school",
        "Children go to kindergarten when they are 5 years old They go to elementary school from ages 6 through 11 (1-5 grades), middle school from ages 12 through 14 (6-8 grades) and high school from ages 15 through 19 (9-12 grades)",
        "About 90 percent of all children attend public school, which is free.",
        "The other 10 percent go I private schools, which often include religious education"
    ]
    
    var name: String?
    
    private func setupNavigation() {
        navigationItem.title = name
    }
    
    //MARK: Setup UI
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: LeftTableViewCell.identifier)
        tableView.register(RightTableViewCell.self, forCellReuseIdentifier: RightTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: UIElements
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.separatorStyle = .none
        return tableView
    }()
}



//MARK: Lifecycle
extension ConversationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        setupTableView()
        // Do any additional setup after loading the view.
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row % 2 == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: LeftTableViewCell.identifier, for: indexPath) as? LeftTableViewCell
            cell?.configure(model[indexPath.row])
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RightTableViewCell.identifier, for: indexPath) as? RightTableViewCell
            cell?.configure(model[indexPath.row])
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
}
