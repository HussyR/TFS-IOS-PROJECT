//
//  ConversationTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 06.03.2022.
//

import UIKit

protocol ConversationCellConfiguration : class {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
    
}

class ConversationTableViewCell: UITableViewCell, ConversationCellConfiguration {
    
    //MARK: Properties
    static let identifier = "ConversationTableViewCell"
    var name: String? = "Name"
    var message: String? = "Message"
    var date: Date? = nil
    var online: Bool = true
    var hasUnreadMessages: Bool = true
    var dateFormatter: DateFormatter?
    
    //MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        messageLabel.text = ""
        dateLabel.text = ""
    }
    
   
   //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    //MARK: Layout
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(avatarImageView)
        
        let height = avatarImageView.heightAnchor.constraint(equalToConstant: 48)
        height.priority = UILayoutPriority(999)
        
        dateLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            height,
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor)
        ])
        
    }
    
    //MARK: Configuration
    
    public func configure(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        updateUI()
    }
    
    private func updateUI() {
        dateLabel.alpha = 1
//         Имя
        nameLabel.text = name
//         Последние сообщение
        if let message = message {
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: 13)
        } else {
            messageLabel.text = "No messages yet"
            messageLabel.font = .boldSystemFont(ofSize: 13)
            dateLabel.alpha = 0 // Если нет сообщения, то и нет даты сообщения
        }
//         Дата
        dateFormatter = DateFormatter()
        
        let limitDate = Date(timeIntervalSinceNow: -60*60*24)
        guard let date = date else {return}
        if date.timeIntervalSince(limitDate) >= 0 {
            dateFormatter?.dateFormat = "HH:mm"
        } else {
            dateFormatter?.dateFormat = "dd MMM"
        }
        dateLabel.text = dateFormatter?.string(from: date)
        
//        Online
        contentView.backgroundColor = (online ? .yellow.withAlphaComponent(0.04): .white)
        
//        Has unread messages
        guard message != nil else {return}
        messageLabel.font = (hasUnreadMessages ? .boldSystemFont(ofSize: 13) : .systemFont(ofSize: 13))
    }
    

    //MARK: UIElements
    

    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = .blue
        imageView.layer.cornerRadius = 24
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .yellow
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
//        label.backgroundColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: Others
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
