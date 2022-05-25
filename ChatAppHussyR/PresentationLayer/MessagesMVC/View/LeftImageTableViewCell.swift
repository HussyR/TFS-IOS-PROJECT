//
//  LeftImageTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 28.04.2022.
//

import UIKit

class LeftImageTableViewCell: UITableViewCell, ImageTableViewCellProtocol {

    var image: UIImage?
    var name: String?
    static let identifier = "LeftImageTableViewCell"
    
    // MARK: - UIElements
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: - INIT
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    // MARK: - UISetup
    
    private func setupLayout() {
        contentView.addSubview(backView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(myImageView)
        
        let constaints = [
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            nameLabel.bottomAnchor.constraint(equalTo: myImageView.topAnchor, constant: -8),
            
            myImageView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            myImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            myImageView.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            myImageView.heightAnchor.constraint(equalTo: myImageView.widthAnchor),
            
            backView.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor, constant: 5),
            backView.leadingAnchor.constraint(equalTo: myImageView.leadingAnchor, constant: -5),
            backView.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -5),
            backView.bottomAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 5)
        ]
        
        NSLayoutConstraint.activate(constaints)
    }
    
    // MARK: - Configuration
    
    public func configure(_ image: UIImage) {
        self.image = image
        updateUI()
    }
    
    public func configure(name: String) {
        self.name = name
        updateUI()
    }
    
    public func configure(theme: Theme) {
        switch theme {
        case .classic:
            contentView.backgroundColor = .white
            backView.backgroundColor = .lightGray
        case .day:
            contentView.backgroundColor = .white
            backView.backgroundColor = .lightGray
        case .night:
            contentView.backgroundColor = .black
            backView.backgroundColor = .white.withAlphaComponent(0.2)
        }
    }
    
    public func changeActivity(isActive: Bool) {
        if isActive {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
    
    private func updateUI() {
        myImageView.image = image
        nameLabel.text = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
