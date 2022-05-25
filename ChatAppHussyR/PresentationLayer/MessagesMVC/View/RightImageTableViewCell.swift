//
//  RightImageTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 28.04.2022.
//

import UIKit

protocol ImageTableViewCellProtocol {
    func configure(_ image: UIImage)
    func changeActivity(isActive: Bool)
}

class RightImageTableViewCell: UITableViewCell, ImageTableViewCellProtocol {

    var image: UIImage?
    static let identifier = "RightImageTableViewCell"
    
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
        contentView.addSubview(myImageView)
        
        let constaints = [
            myImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            myImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            myImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            myImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            myImageView.heightAnchor.constraint(equalTo: myImageView.widthAnchor),
            
            backView.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor, constant: 5),
            backView.leadingAnchor.constraint(equalTo: myImageView.leadingAnchor, constant: -5),
            backView.topAnchor.constraint(equalTo: myImageView.topAnchor, constant: -5),
            backView.bottomAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 5)
        ]
        
        NSLayoutConstraint.activate(constaints)
    }
    
    // MARK: - Configuration
    
    public func configure(_ image: UIImage) {
        self.image = image
        updateUI()
    }
    
    public func configure(theme: Theme) {
        switch theme {
        case .classic:
            contentView.backgroundColor = .white
            backView.backgroundColor = .green.withAlphaComponent(0.5)
        case .day:
            contentView.backgroundColor = .white
            backView.backgroundColor = .systemBlue
        case .night:
            contentView.backgroundColor = .black
            backView.backgroundColor = .white.withAlphaComponent(0.3)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
