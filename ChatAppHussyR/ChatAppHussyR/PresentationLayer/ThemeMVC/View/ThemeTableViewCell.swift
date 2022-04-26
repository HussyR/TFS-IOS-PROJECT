//
//  ThemeTableViewCell.swift
//  ChatAppHussyR
//
//  Created by Данил on 14.03.2022.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    static let identifier = "ThemeTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .green.withAlphaComponent(0)
        backgroundColor = .green.withAlphaComponent(0)
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print(#function)

        if isSelected {
            customBackgroundView.layer.borderWidth = 2
            customBackgroundView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            customBackgroundView.layer.borderWidth = 0
            customBackgroundView.layer.borderColor = UIColor.clear.cgColor
        }
        
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(customBackgroundView)
        contentView.addSubview(label)
        
        customBackgroundView.addSubview(leftBackgroundView)
        customBackgroundView.addSubview(rightBackgroundView)
        
        NSLayoutConstraint.activate([
            customBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customBackgroundView.heightAnchor.constraint(equalToConstant: 60),
            customBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.topAnchor.constraint(equalTo: customBackgroundView.bottomAnchor),
            
            leftBackgroundView.leadingAnchor.constraint(equalTo: customBackgroundView.leadingAnchor, constant: 10),
            leftBackgroundView.topAnchor.constraint(equalTo: customBackgroundView.topAnchor, constant: 10),
            leftBackgroundView.heightAnchor.constraint(equalToConstant: 35),
            leftBackgroundView.trailingAnchor.constraint(equalTo: rightBackgroundView.leadingAnchor, constant: -20),
            leftBackgroundView.widthAnchor.constraint(equalTo: rightBackgroundView.widthAnchor),
            
            rightBackgroundView.trailingAnchor.constraint(equalTo: customBackgroundView.trailingAnchor, constant: -10),
            rightBackgroundView.topAnchor.constraint(equalTo: customBackgroundView.topAnchor, constant: 15),
            rightBackgroundView.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    // MARK: - Configure
    
    public func configure(with backgroundColor: UIColor, _ leftColor: UIColor, _ rightColor: UIColor, _ text: String) {
        customBackgroundView.backgroundColor = backgroundColor
        leftBackgroundView.backgroundColor = leftColor
        rightBackgroundView.backgroundColor = rightColor
        label.text = text
    }
    
    // MARK: - UIElements
    
    let customBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let leftBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        return view
    }()
    
    let rightBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.layer.cornerRadius = 5
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Classic"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Others
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
