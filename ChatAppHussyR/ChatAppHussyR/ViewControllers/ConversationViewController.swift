//
//  ConversationViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 07.03.2022.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    var theme = Theme.classic
    
    var channel: Channel?
    var messages = [Message]()
    private lazy var db = Firestore.firestore()
    private lazy var reference = db.collection("channels")
    
    var uuid: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    
    //MARK: Navigation and theme
    private func setupNavigation() {
        navigationItem.title = channel?.name
    }
    
    private func setupTheme() {
        switch theme {
        case .night:
            view.backgroundColor = .black
            tableView.backgroundColor = .black
        default:
            view.backgroundColor = .white
            tableView.backgroundColor = .white
        }
    }
    
    //MARK: Logic
    
    private func fetchAllMessagesForChannel() {
        guard let channel = channel else {return}
        db.collection("channels").document(channel.identifier).collection("messages").addSnapshotListener { [weak self] snap, error in
            guard let self = self,
                  error == nil
            else {return}
            var newMessages = [Message]()
            snap?.documents.forEach { [weak self] in
                guard let self = self else {return}
                let message = self.makeMessage(model: $0.data())
                newMessages.append(message)
            }
            self.messages = newMessages.sorted {
                $0.created <= $1.created
            }
            self.tableView.reloadData()
        }
    }
    
    private func makeMessage(model: [String: Any]) -> Message {
        let content = (model["content"] as? String) ?? ""
        let senderID = (model["senderID"] as? String) ?? ""
        let date = (model["created"] as? Timestamp)?.dateValue() ?? Date()
        let senderName = (model["senderName"] as? String) ?? ""
        let newMessage = Message(content: content, created: date, senderId: senderID, senderName: senderName)
        return newMessage
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
        fetchAllMessagesForChannel()
//        guard let channel = channel else {return}
//        db.collection("channels").document(channel.identifier).collection("messages").addDocument(data: ["content":"hello", "senderID": uuid, "created": Timestamp(date: Date()), "senderName": "Danila"])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTheme()
        tableView.reloadData()
    }
    
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if message.senderId == uuid {
            let cell = tableView.dequeueReusableCell(withIdentifier: RightTableViewCell.identifier, for: indexPath) as? RightTableViewCell
            cell?.configure(message.content)
            cell?.configure(theme: theme)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LeftTableViewCell.identifier, for: indexPath) as? LeftTableViewCell
            cell?.configure(message)
            cell?.configure(theme: theme)
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
}
