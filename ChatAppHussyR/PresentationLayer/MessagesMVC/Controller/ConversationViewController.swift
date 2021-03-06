//
//  ConversationViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 07.03.2022.
//

import UIKit
import Firebase
import CoreData

class ConversationViewController: UIViewController {
    
    var theme = Theme.classic
    
    var channel: Channel?
    var coreDataService: CoreDataServiceProtocol?
    var firebaseService: FirebaseServiceProtocol?
    var networkService: NetworkServiceProtocol?
    var isFirstLaunch = true
    
    private lazy var fetchedResultController: NSFetchedResultsController<DBMessage> = {
        let fetch = DBMessage.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DBMessage.channel.identifier), channel?.identifier ?? "")
        fetch.predicate = predicate
        let sortD = NSSortDescriptor(key: #keyPath(DBMessage.created), ascending: true)
        fetch.sortDescriptors = [sortD]
        
        guard let coreDataService = coreDataService else {
            fatalError("error")
        }
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: coreDataService.contextForFetchedResultController,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return controller
    }()
    
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
        sendImageButton.addTarget(self, action: #selector(showImages), for: .touchUpInside)
    }
    
    // MARK: - Logic
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardMove),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardMove),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    private func fetchAllMessagesForChannel() {
        guard let channel = channel,
              let firebaseService = firebaseService,
              let coreDataService = self.coreDataService
        else { return }
        
        firebaseService.getMessages(channelID: channel.identifier) { snap in
            coreDataService.updateRemoveOrDeleteMessages(objectsForUpdate: snap.documentChanges, channelID: channel.identifier)
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
        firebaseService?.addMessage(message: message, channelID: channel.identifier)
        textField.text = ""
    }
    
    @objc private func changeValueOfTextField() {
        let text = textField.text ?? ""
        sendButton.isEnabled = text.isEmpty ? false : true
    }
    
    private func fillCellWithImage(indexPath: IndexPath, url: String) {
        DispatchQueue.global().async {
            self.networkService?.loadPicture(url: url) { result in
                switch result {
                case .success(let imageData):
                    DispatchQueue.main.async {
                        let cell = self.tableView.cellForRow(at: indexPath) as? ImageTableViewCellProtocol
                        let resImage: UIImage?
                        if let image = UIImage(data: imageData) {
                            resImage = image
                        } else {
                            resImage = UIImage(named: "not-found")
                        }
                        guard let resImage = resImage else { return }
                        cell?.configure(resImage)
                        cell?.changeActivity(isActive: false)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func showImages() {
        let vc = ChoosePhotoViewController()
        vc.networkService = networkService
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func verifyUrl (urlString: String) -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) {
            return match.range.length == urlString.utf16.count
        } else {
            return false
        }
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
        tableView.register(RightImageTableViewCell.self, forCellReuseIdentifier: RightImageTableViewCell.identifier)
        tableView.register(LeftImageTableViewCell.self, forCellReuseIdentifier: LeftImageTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupViewForSendMessage() {
        viewForSendMessage.addSubview(textField)
        viewForSendMessage.addSubview(sendButton)
        viewForSendMessage.addSubview(sendImageButton)
        
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: viewForSendMessage.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: viewForSendMessage.bottomAnchor),
            sendButton.trailingAnchor.constraint(equalTo: viewForSendMessage.trailingAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 58),
            
            sendImageButton.centerYAnchor.constraint(equalTo: viewForSendMessage.centerYAnchor),
            sendImageButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            sendImageButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendImageButton.heightAnchor.constraint(equalToConstant: 24),
            sendImageButton.widthAnchor.constraint(equalToConstant: 24),
            
            textField.leadingAnchor.constraint(equalTo: viewForSendMessage.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendImageButton.leadingAnchor, constant: -8),
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
        view.backgroundColor = .lightGray
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
    
    let sendImageButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "person.crop.rectangle.fill")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
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
        
        fetchAllMessagesForChannel()
        setupNotifications()
        
        fetchedResultController.delegate = self
        
        do {
          try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
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
        
        let dbmessage = fetchedResultController.object(at: indexPath)
        let message = Message(
            content: dbmessage.content ?? "",
            created: dbmessage.created ?? Date(),
            senderId: dbmessage.senderId ?? "",
            senderName: dbmessage.senderName ?? "")
        if message.senderId == uuid {
            if verifyUrl(urlString: message.content) {
                let cell = tableView.dequeueReusableCell(withIdentifier: RightImageTableViewCell.identifier, for: indexPath) as? RightImageTableViewCell
                cell?.configure(theme: theme)
                cell?.changeActivity(isActive: true)
                fillCellWithImage(indexPath: indexPath, url: message.content)
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: RightTableViewCell.identifier, for: indexPath) as? RightTableViewCell
                cell?.configure(message.content)
                cell?.configure(theme: theme)
                return cell ?? UITableViewCell()
            }
        } else {
            if verifyUrl(urlString: message.content) {
                let cell = tableView.dequeueReusableCell(withIdentifier: LeftImageTableViewCell.identifier, for: indexPath) as? LeftImageTableViewCell
                cell?.configure(name: message.senderName)
                cell?.configure(theme: theme)
                cell?.changeActivity(isActive: true)
                fillCellWithImage(indexPath: indexPath, url: message.content)
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LeftTableViewCell.identifier, for: indexPath) as? LeftTableViewCell
                cell?.configure(message)
                cell?.configure(theme: theme)
                return cell ?? UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.endEditing(true)
    }
    
}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                return
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

extension ConversationViewController: ChoosePhotoViewControllerDelegate {
    func choosePhotoViewControllerDelegate(image: UIImage) {
        print("передано фото")
    }
    
    func choosePhotoViewControllerDelegate(url: String) {
        self.textField.text = url
        self.sendButton.isEnabled = true
    }
}
