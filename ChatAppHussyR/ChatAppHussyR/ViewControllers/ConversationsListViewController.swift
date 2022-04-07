//
//  ConversationsListViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 06.03.2022.
//

import UIKit
import Firebase
import CoreData

class ConversationsListViewController: UIViewController {

    private lazy var db = Firestore.firestore()
    private lazy var channelsReference = db.collection("channels")
    private let newCoreDataStack = NewCoreDataStack()
    
    var theme = Theme.classic
    var channels = [Channel]()
    var passedName: String?
    var uuid: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
        fetchAllChannelsFirebase()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataContextSave(notification:)),
                                               name: Notification.Name.NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTheme()
        tableView.reloadData()
    }
    
    // MARK: - Firebase get all channels
    
    private func fetchAllChannelsFirebase() {
        channelsReference.order(by: "lastActivity", descending: true).addSnapshotListener { [weak self] snap, error in
            guard let self = self,
                  error == nil
            else { return }
            self.newCoreDataStack.performSave { context in
                let fetch: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
                guard let dbchannels = try? context.fetch(fetch) else { return }
                snap?.documentChanges.forEach({ [weak self] documentC in
                    guard let self = self else { return }
                    let channel = Channel(dictionary: documentC.document.data(), identifier: documentC.document.documentID)
                    if let dbchannelForChange = self.doesChannelExist(id: channel.identifier, dbChannels: dbchannels) {
                        dbchannelForChange.lastActivity = channel.lastActivity
                        dbchannelForChange.lastMessage = channel.lastMessage
                    } else {
                        let dbchannel = DBChannel(context: context)
                        dbchannel.name = channel.name
                        dbchannel.identifier = channel.identifier
                        dbchannel.lastMessage = channel.lastMessage
                        dbchannel.lastActivity = channel.lastActivity
                    }
                })
            }
        }
    }
    
    private func doesChannelExist(id: String, dbChannels: [DBChannel]) -> DBChannel? {
        guard let channel = dbChannels.filter({ $0.identifier == id }).first else { return nil }
        return channel
    }
    
    @objc private func coreDataContextSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let dbchannelsforshow = self.newCoreDataStack.fecthChannels()
            let channelsForTableView = dbchannelsforshow.map { dbchannel in
                return Channel(identifier: dbchannel.identifier ?? "",
                               name: dbchannel.name ?? "",
                               lastMessage: dbchannel.lastMessage ?? "",
                               lastActivity: dbchannel.lastActivity ?? Date())
            }
            self.channels = channelsForTableView.sorted(by: {
                $0.lastActivity >= $1.lastActivity
            })
            self.tableView.reloadData()
        }
    }
    
    // MARK: - SetupUI
    
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
    
    // MARK: - Logic
    
    @objc private func createNewChannelAction() {
        let alert = UIAlertController(title: "Создать новый канал", message: "Впишите название канала", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Channel name"
        }
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let tf = alert.textFields?[0],
                  let name = tf.text,
                  !name.isEmpty
            else { return }
            self?.writeChannelToFirebase(name: name)
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func writeChannelToFirebase(name: String) {
        let ref = channelsReference.addDocument(data: ["name": name])
        let message = Message(content: "First message", created: Date(), senderId: uuid, senderName: "Danila")
        ref.collection("messages").addDocument(data: message.toDict())
    }
    
    // MARK: - Navigation and theme
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        
        let firstRightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createNewChannelAction))
        let secondRightButton = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(presentPersonVC))
        
        navigationItem.rightBarButtonItems = [secondRightButton, firstRightButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(presentSettingsVC))
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
            guard let self = self else { return }
            self.theme = theme
            self.setupTheme()
            DispatchQueue.global(qos: .background).async {
                DataManagerGCD.shared.writeThemeData(theme: theme.rawValue)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UIElements
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black.withAlphaComponent(0.05)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        return tableView
    }()
}

    // MARK: - UITableViewDelegate, UITableViewDataSource

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath)
        guard let cell = cell as? ConversationTableViewCell else { return cell }
        
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
        vc.newCoreDataStack = self.newCoreDataStack
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
