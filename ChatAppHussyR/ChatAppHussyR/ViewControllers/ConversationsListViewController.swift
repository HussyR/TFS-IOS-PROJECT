//
//  ConversationsListViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 06.03.2022.
//

import UIKit

class ConversationsListViewController: UIViewController {

    
    var theme = Theme.classic
    let offlineData = MyData.getOfflineData()
    let onlineData = MyData.getOnlineData()
    var passedName : String?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTheme()
        tableView.reloadData()
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
    
    //MARK: navigation and theme
    
    private func setupNavigationBar() {
//        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Tinkoff Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(presentPersonVC))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain,  target: self, action: #selector(presentSettingsVC))
    }
    
    private func setupTheme() {
        switch theme {
        case .night:
            tableView.backgroundColor = .black
            view.backgroundColor = .black
            tableView.backgroundColor = .black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barTintColor = .black
        default:
            view.backgroundColor = .white
            tableView.backgroundColor = .white
            tableView.backgroundColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    
    
    @objc private func presentPersonVC() {
        let vc = ProfileViewController()
        vc.theme = theme
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func presentSettingsVC() {
        let vc = ThemesViewController()
//        vc.delegate = self
        vc.theme = theme
        vc.closure = { [weak self] theme in
            guard let self = self else {return}
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
            self.theme = theme
            self.setupTheme()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: UIElements
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black.withAlphaComponent(0.05)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        return tableView
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
        cell.configure(theme: theme)
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
    // MARK: - Navigation + didSelectRow

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            passedName = onlineData[indexPath.row].name
        } else {
            passedName = offlineData[indexPath.row].name
        }
        let vc = ConversationViewController()
        vc.name = passedName
        vc.theme = theme
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ConversationsListViewController: ThemesPickerDelegate {
    func themeViewController(themeVC: ThemesViewController, theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        self.theme = theme
        self.setupTheme()
    }
}
