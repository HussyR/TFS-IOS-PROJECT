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
    
    private lazy var fetchedResultController: NSFetchedResultsController<DBChannel> = {
        let fetch = DBChannel.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(DBChannel.lastActivity), ascending: false)
        fetch.sortDescriptors = [sort]
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: coreDataService.contextForFetchedResultController,
            sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    
    let coreDataService: CoreDataServiceProtocol = CoreDataService()
    let firebaseService: FirebaseServiceProtocol = FirebaseService()
    let networkService: NetworkServiceProtocol = NetworkService()
    
    var isFirstLaunch: Bool = true
    
    var theme = Theme.classic
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
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTheme()
        tableView.reloadData()
    }
    
    // MARK: - Firebase get all channels
    
    private func fetchAllChannelsFirebase() {
        
        firebaseService.getChannels { [weak self] snap in
            guard let self = self else { return }
            self.coreDataService.updateRemoveOrDeleteChannels(objectsForUpdate: snap.documentChanges, isFirstLaunch: self.isFirstLaunch)
        }
        
//        firebaseService.addSnapshotListenerToChannel { [weak self] snap in
//            guard let self = self
//            else { return }
//            self.coreDataService.updateRemoveOrDeleteChannels(objectsForUpdate: snap.documentChanges, isFirstLaunch: self.isFirstLaunch)
//        }
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
            guard let self = self,
                  let tf = alert.textFields?[0],
                  let name = tf.text,
                  !name.isEmpty
            else { return }
            self.firebaseService.addChannel(name: name, uuid: self.uuid)
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation and theme
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        
        let firstRightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createNewChannelAction))
        let secondRightButton = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: #selector(presentPersonVC))
        
        navigationItem.rightBarButtonItems = [secondRightButton, firstRightButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
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
        vc.transitioningDelegate = self
        vc.networkService = networkService
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
                DataManagerGCDService.shared.writeThemeData(theme: theme.rawValue)
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
        
        let channel = fetchedResultController.object(at: indexPath)
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
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channel = fetchedResultController.object(at: indexPath)
            firebaseService.removeChannelWithID(channel.identifier ?? "")
        }
    }
    
    // MARK: - Navigation + didSelectRow

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            passedName = onlineData[indexPath.row].name
//        } else {
//            passedName = offlineData[indexPath.row].name
//        }
        let vc = ConversationViewController()
        let dbchannel = fetchedResultController.object(at: indexPath)
        let channel = Channel(identifier: dbchannel.identifier ?? "",
                              name: dbchannel.name ?? "",
                              lastMessage: dbchannel.lastMessage ?? "",
                              lastActivity: dbchannel.lastActivity ?? Date())
        vc.channel = channel
        vc.coreDataService = self.coreDataService
        vc.firebaseService = self.firebaseService
        vc.networkService = self.networkService
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

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    
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

extension ConversationsListViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        return CustomTransition()
    }
}
