//
//  ConversationsListViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 06.03.2022.
//

import UIKit
import Firebase

class ConversationsListViewController: UIViewController {

    private lazy var db = Firestore.firestore()
    private lazy var channelsReference = db.collection("channels")
    
    var theme = Theme.classic
    var channels = [Channel]()
    var passedName : String?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
        fetchAllChannelsFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTheme()
        tableView.reloadData()
    }
    
    //MARK: Firebase get all channels
    
    private func fetchAllChannelsFirebase() {
        channelsReference.addSnapshotListener { [weak self] snap, error in
            guard let self = self,
                  error == nil
            else {return}
            var newChannels = [Channel]()
            snap?.documents.forEach { [weak self] in
                guard let self = self else {return}
                let newChannel = self.makeChannel(model: $0.data(), id: $0.documentID)
                newChannels.append(newChannel)
            }
//            self.channels = newChannels.sorted {
//                $0.lastActivity <= $1.lastActivity
//            }
            self.channels = newChannels
            self.tableView.reloadData()
        }
    }
    
    private func makeChannel(model: [String: Any], id: String) -> Channel {
        let name = model["name"] as? String ?? ""
        let lastMessage = model["lastMessage"] as? String
        let date = (model["lastActivity"] as? Timestamp)?.dateValue()
        let newChannel = Channel(identifier: id, name: name, lastMessage: lastMessage, lastActivity: date)
        return newChannel
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
    
    //MARK: Logic
    
    @objc private func createNewChannelAction() {
        let alert = UIAlertController(title: "Создать новый канал", message: "Впишите название канала", preferredStyle: .alert)
        alert.addTextField()
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let tf = alert.textFields?[0],
                  let name = tf.text
            else {return}
            self?.writeChannelToFirebase(name: name)
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        
        self.present(alert, animated: true)
    }
    
    private func writeChannelToFirebase(name: String) {
        channelsReference.addDocument(data: ["name": name])
    }
    
    //MARK: Navigation and theme
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        
        let firstRightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createNewChannelAction))
        let secondRightButton = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(presentPersonVC))
        
        navigationItem.rightBarButtonItems = [secondRightButton, firstRightButton]
        
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
        vc.theme = theme
        vc.closure = { [weak self] theme in
            guard let self = self else {return}
            self.theme = theme
            self.setupTheme()
            DispatchQueue.global(qos: .background).async {
                DataManagerGCD.shared.writeThemeData(theme: theme.rawValue)
            }
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
        
        let channel = channels[indexPath.row]
        cell.configure(name: channel.name, message: channel.lastMessage, date: channel.lastActivity, online: false, hasUnreadMessages: false)
        
//        let i = indexPath.row
//        if indexPath.section == 0 {
//            let model = onlineData[i]
//            cell.configure(name: model.name, message: model.message, date: model.date, online: model.online, hasUnreadMessages: model.hasUnreadMessages)
//        } else {
//            let model = offlineData[i]
//            cell.configure(name: model.name, message: model.message, date: model.date, online: model.online, hasUnreadMessages: model.hasUnreadMessages)
//        }
        cell.configure(theme: theme)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    // MARK: - Navigation + didSelectRow

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            passedName = onlineData[indexPath.row].name
//        } else {
//            passedName = offlineData[indexPath.row].name
//        }
        let vc = ConversationViewController()
        vc.channel = channels[indexPath.row]
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
