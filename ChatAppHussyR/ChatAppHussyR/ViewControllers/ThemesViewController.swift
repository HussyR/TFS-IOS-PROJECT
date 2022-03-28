//
//  SettingsViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 13.03.2022.
//

import UIKit

enum Theme: Int {
    case classic = 0
    case day = 1
    case night = 2
}

protocol ThemesPickerDelegate: AnyObject {
    func themeViewController(themeVC: ThemesViewController, theme: Theme)
}

class ThemesViewController: UIViewController {
    
    var theme = Theme.classic
    weak var delegate: ThemesPickerDelegate?
    var closure: ((Theme) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTheme()
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        view.addSubview(tableView)
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ]
        NSLayoutConstraint.activate(constraints)
        tableView.backgroundColor = .clear
        tableView.register(ThemeTableViewCell.self, forCellReuseIdentifier: ThemeTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // MARK: - Navigation and theme
    
    private func setupNavigation() {
        navigationItem.title = "Settings"
    }
    
    private func setupTheme() {
        switch theme {
        case .night:
            view.backgroundColor = .black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]            
        default:
            view.backgroundColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
    }
    
    // MARK: - UIElements
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
    
}

    // MARK: - UITableViewDataSource, UITableViewDelegate

extension ThemesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath)
        guard let cell = cell as? ThemeTableViewCell else { return cell }
        
        switch indexPath.row {
        case 0:
            cell.configure(with: .white, .lightGray, .green.withAlphaComponent(0.4), "Classic")
        case 1:
            cell.configure(with: .white, .lightGray, .systemBlue, "Day")
        case 2:
            cell.configure(with: .black, .white.withAlphaComponent(0.2), .white.withAlphaComponent(0.3), "Night")
        default:
            print("error")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let theme = Theme(rawValue: indexPath.row) else { return }
        self.theme = theme
        setupTheme()
        if let closure = closure {
            closure(theme)
        }
//        delegate?.themeViewController(themeVC: self, theme: theme)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if theme.rawValue == indexPath.row {
            cell.setSelected(true, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
}
