//
//  RightTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 09.03.2022.
//

import UIKit

protocol MessageCellConfiguration {
    var message: String? {get set}
}

class RightTableViewCell: UITableViewCell, MessageCellConfiguration {
    
    var message: String? = ""

    static let identifier = "RightTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    //MARK: Others
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup layout
    
    private func setupLayout() {
        contentView.addSubview(backView)
        contentView.addSubview(messageLabel)
        
        let constaints = [
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            backView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 5),
            backView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -5),
            backView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -5),
            backView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
        ]
        
        NSLayoutConstraint.activate(constaints)
        
    }
    
    public func configure(_ message: String) {
        self.message = message
        updateUI()
    }
    
    public func configure(theme: Theme) {
        switch theme {
        case .classic:
            contentView.backgroundColor = .white
            backView.backgroundColor = .green.withAlphaComponent(0.5)
            messageLabel.textColor = .white
        case .day:
            contentView.backgroundColor = .white
            backView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
        case .night:
            contentView.backgroundColor = .black
            backView.backgroundColor = .white.withAlphaComponent(0.3)
            messageLabel.textColor = .white
        }
    }
    
    private func updateUI() {
        messageLabel.text = message
    }
    
    //MARK: UIElements
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
}
