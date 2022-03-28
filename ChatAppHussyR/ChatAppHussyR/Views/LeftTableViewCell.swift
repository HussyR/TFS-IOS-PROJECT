//
//  LeftTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 09.03.2022.
//

import UIKit

class LeftTableViewCell: UITableViewCell, MessageCellConfiguration {

    var message: String?
    var name: String?
    
    static let identifier = "LeftTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    //MARK: Others
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: SetupLayout
    
    private func setupLayout() {
        contentView.addSubview(backView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        
        let constaints = [
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            nameLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            
            backView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 5),
            backView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -5),
            backView.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -5),
            backView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
        ]
        
        NSLayoutConstraint.activate(constaints)
    }
    
    public func configure(_ message: Message) {
        self.name = message.senderName
        self.message = message.content
        updateUI()
    }
    
    public func configure(theme: Theme) {
        switch theme {
        case .classic:
            contentView.backgroundColor = .white
            backView.backgroundColor = .lightGray
            messageLabel.textColor = .white
        case .day:
            contentView.backgroundColor = .white
            backView.backgroundColor = .lightGray
            messageLabel.textColor = .white
        case .night:
            contentView.backgroundColor = .black
            backView.backgroundColor = .white.withAlphaComponent(0.2)
            messageLabel.textColor = .white
        }
    }
    
    private func updateUI() {
        messageLabel.text = message
        nameLabel.text = name
    }
    
    //MARK: UIElements
    
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.25)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    
}
