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
    
    var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Navigation and theme
    
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
    
    // MARK: - SetupActions
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(writeNewMessage), for: .touchUpInside)
        textField.addTarget(self, action: #selector(changeValueOfTextField), for: .editingChanged)
    }
    
    // MARK: - Logic
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMove), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMove), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func fetchAllMessagesForChannel() {
        guard let channel = channel else { return }
        db.collection("channels").document(channel.identifier).collection("messages").addSnapshotListener { [weak self] snap, error in
            guard let self = self,
                  error == nil
            else { return }
            var newMessages = [Message]()
            snap?.documents.forEach {
                let message = Message(dictionary: $0.data())
                newMessages.append(message)
            }
            self.messages = newMessages.sorted {
                $0.created <= $1.created
            }
            self.tableView.reloadData()
        }
    }
    
    @objc private func keyboardMove(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let isShowKeyboardNotification = notification.name == UIResponder.keyboardWillShowNotification
                bottomConstraint?.constant = isShowKeyboardNotification ? -keyboardFrame.height: 0
                view.layoutIfNeeded()
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
                    
                }
            }
        }
    }
    
    @objc private func writeNewMessage() {
        guard let messageText = textField.text,
              !messageText.isEmpty
        else { return }
        let message = Message(content: messageText, created: Date(), senderId: uuid, senderName: "Danila")
        guard let channel = channel else { return }
        db.collection("channels")
            .document(channel.identifier)
            .collection("messages")
            .addDocument(data: message.toDict())
        textField.text = ""
    }
    
    @objc private func changeValueOfTextField() {
        let text = textField.text ?? ""
        sendButton.isEnabled = text.isEmpty ? false : true
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(viewForSendMessage)
        
        bottomConstraint = viewForSendMessage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        guard let bottomConstraint = bottomConstraint else {
            return
        }
        let constraints = [
            bottomConstraint,
            viewForSendMessage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewForSendMessage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewForSendMessage.heightAnchor.constraint(equalToConstant: 48),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewForSendMessage.topAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: LeftTableViewCell.identifier)
        tableView.register(RightTableViewCell.self, forCellReuseIdentifier: RightTableViewCell.identifier)
    }
    
    private func setupViewForSendMessage() {
        viewForSendMessage.addSubview(textField)
        viewForSendMessage.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: viewForSendMessage.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: viewForSendMessage.bottomAnchor),
            sendButton.trailingAnchor.constraint(equalTo: viewForSendMessage.trailingAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 58),
            
            textField.leadingAnchor.constraint(equalTo: viewForSendMessage.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: viewForSendMessage.topAnchor),
            textField.bottomAnchor.constraint(equalTo: viewForSendMessage.bottomAnchor)
        ])
    }
    
    // MARK: - UIElements
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let viewForSendMessage: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter your message..."
        return tf
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
}

// MARK: - Lifecycle

extension ConversationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        setupUI()
        setupViewForSendMessage()
        setupActions()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchAllMessagesForChannel()
        setupNotifications()
        
    }
    
    override func viewWillAppear( _ animated: Bool) {
        super.viewWillAppear(animated)
        setupTheme()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.endEditing(true)
    }
    
}
