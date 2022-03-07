//
//  ConversationsListViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 06.03.2022.
//

import UIKit

class ConversationsListViewController: UIViewController {

    let offlineData = MyData.getOfflineData()
    let onlineData = MyData.getOnlineData()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        view.backgroundColor = .white
    }
    

    //MARK: SetupUI
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: Setup Navigation Bar
    
    private func setupNavigationBar() {
        navigationItem.title = "Tinkoff Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(presentPersonVC))
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @objc private func presentPersonVC() {
        self.present(ViewController(), animated: true, completion: nil)
    }
    
    //MARK: UIElements
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black.withAlphaComponent(0.05)
//        tableView.rowHeight = 80
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        return tableView
    }()
    
    let rightNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()

}
//MARK: UITableViewDelegate, UITableViewDataSource
extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath)
        guard let cell = cell as? ConversationTableViewCell else {return cell}
        
        let i = indexPath.row
        if indexPath.section == 0 {
            let model = onlineData[i]
            cell.configure(name: model.name, message: model.message, date: model.date, online: model.online, hasUnreadMessages: model.hasUnreadMessages)
        } else {
            let model = offlineData[i]
            cell.configure(name: model.name, message: model.message, date: model.date, online: model.online, hasUnreadMessages: model.hasUnreadMessages)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 ? onlineData.count : offlineData.count)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Online"
        case 1: return "History"
        default: return "No way"
        }
    }
}
