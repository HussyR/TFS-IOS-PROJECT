//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit
import Foundation
import AVFoundation

enum SaveMethod {
    case GCD
    case operation
}


class ProfileViewController: UIViewController {

    private let queue = OperationQueue()
    private var operation = DataManagerOperation()
    var theme: Theme = .classic
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var oldSavedName: String?
    var oldSavedDescription: String?
    var oldImage: UIImage?
    var oldImageFlag = false
    
    //MARK: Actions
    
    @objc private func editTapped() {
        print("Выбери изображение профиля")
        let alert = UIAlertController(title: "Изображение профиля", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: {[weak self] _ in
            guard let self = self else {return}
            self.showImagePickerController(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: {[weak self] _ in
            guard let self = self else {return}
            self.showImagePickerController(sourceType: UIImagePickerController.SourceType.camera)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func closeAction() {
        self.dismiss(animated: true)
    }
    
    @objc private func makeEditable() {
        showButtons(show: false)
        isEdit(isEdit: true)
        updateSavedUI()
    }
    
    @objc private func cancelEditing() {
        isEdit(isEdit: false)
        if (hasChanges()) {
            nameTextField.text = oldSavedName
            descriptionTextView.text = oldSavedDescription
            avatarImageView.image = oldImage
        }
    }
    
    @objc private func saveGCD() {
        print(#function)
        showButtons(show: false)
        activityIndicator.startAnimating()
        let profileData = makeProfileModel()
        DispatchQueue.global(qos: .background).async { [weak self] in
            let success = DataManagerGCD.shared.writeProfileData(model: profileData)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.showAlertWhenSuccessOrFailSave(isSuccess: success, method: .GCD)
            }
        }
    }
    
    @objc private func saveOperation() {
        showButtons(show: false)
        activityIndicator.startAnimating()
        let profileData = makeProfileModel()
        
        operation.profileData = profileData
        operation.completion = { success in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.showAlertWhenSuccessOrFailSave(isSuccess: success, method: .operation)
                print(success)
            }
        }
        queue.addOperation(operation)
    }
    
    //MARK: Logic
    
    private func makeProfileModel() -> ProfileData {
        let name = nameTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        let imageData = avatarImageView.image?.pngData()
        let profileData = ProfileData(name: name, description: description, image: imageData)
        return profileData
    }
    
    
    //MARK: Подумать над общим вызовом
    private func saveGCDorOperation() {
        
    }
    
    // Метод показывает алерты и в случае нажатия повторения вызывает соотв. методы сохранения
    private func showAlertWhenSuccessOrFailSave(isSuccess: Bool, method: SaveMethod) {
        if (isSuccess) {
                print("data write")
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.showButtons(show: true)
                    self.isEdit(isEdit: false)
                }))
                self.updateSavedUI()
                self.present(alert, animated: true)
        } else {
            print("data not write")
            let alert = UIAlertController(title: "Ошибка", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.showButtons(show: true)
            }))
            alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] action in
                guard let self = self else {return}
                switch method {
                case .GCD:
                    self.saveGCD()
                case .operation:
                    self.saveOperation()
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func readProfileData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let model = DataManagerGCD.shared.readProfileData() else {return}
            DispatchQueue.main.async {
                let description = (model.description.isEmpty ? "description": model.description)
                self.nameTextField.text = model.name
                self.descriptionTextView.text = description
                if let data = model.image,
                   let image = UIImage(data: data) {
                    self.avatarImageView.image = image
                }
                self.updateSavedUI()
            }
        }
    }
    
    private func updateSavedUI() {
        oldSavedName = nameTextField.text
        oldSavedDescription = descriptionTextView.text
        oldImage = avatarImageView.image
        oldImageFlag = false
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.mediaTypes = ["public.image"]
        vc.allowsEditing = true
        vc.delegate = self
        print(AVCaptureDevice.authorizationStatus(for: .video).rawValue)
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {return}
        if sourceType == .photoLibrary {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized ||
                  AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Разрешите доступ", message: "Выбранный вами способ недоступен", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel))
            self.show(alert, sender: self)
        }
    }
    
    private func isEdit(isEdit: Bool) {
        editTextButton.isHidden = isEdit
        cancelButton.isHidden = !isEdit
        saveOperationButton.isHidden = !isEdit
        saveGCDButton.isHidden = !isEdit
        nameTextField.isUserInteractionEnabled = isEdit
        descriptionTextView.isUserInteractionEnabled = isEdit
    }
    
    private func hasChanges() -> Bool {
        if (nameTextField.text != oldSavedName ||
            descriptionTextView.text != oldSavedDescription ||
            oldImageFlag) {
            return true
        }
        return false
    }
    
    private func showButtons(show: Bool) {
        saveGCDButton.isEnabled = show
        saveOperationButton.isEnabled = show
        
        if show {
            saveGCDButton.alpha = 1
            saveOperationButton.alpha = 1
        } else {
            saveGCDButton.alpha = 0.5
            saveOperationButton.alpha = 0.5
        }
        
    }
    
    //MARK: Theme
    
    private func setupTheme() {
        switch theme {
        case .night:
            view.backgroundColor = .black
            myProfileLabel.textColor = .white
            navigationView.backgroundColor = .clear
            nameTextField.textColor = .white
            descriptionTextView.textColor = .white
        default:
            view.backgroundColor = .white
            myProfileLabel.textColor = .black
            navigationView.backgroundColor = .black.withAlphaComponent(0.04)
            nameTextField.textColor = .black
            descriptionTextView.textColor = .black
        }
    }
    //MARK:  Hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: Setup UI Actions
    
    private func setupUIActions() {
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        editAvatarButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editTextButton.addTarget(self, action: #selector(makeEditable), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
        saveGCDButton.addTarget(self, action: #selector(saveGCD), for: .touchUpInside)
        saveOperationButton.addTarget(self, action: #selector(saveOperation), for: .touchUpInside)
    }
    
    //MARK: Setup UI Layout
    
    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(myProfileLabel)
        navigationView.addSubview(closeButton)
        
        view.addSubview(avatarImageView)
        view.addSubview(editAvatarButton)
        
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveGCDButton)
        view.addSubview(saveOperationButton)
        view.addSubview(cancelButton)
        view.addSubview(editTextButton)
        view.addSubview(activityIndicator)
        
        // Чтобы настроить адаптацию под маленькие устройства
        let avatarWidthConstraint = avatarImageView.widthAnchor.constraint(equalToConstant: 240)
        avatarWidthConstraint.priority = UILayoutPriority(999)

        
        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 96),
            
            myProfileLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            myProfileLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
            
            closeButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            
            avatarImageView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 7),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarWidthConstraint,
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 68),
            avatarImageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -68),
            
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 22),
            
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.topAnchor.constraint(equalTo: editAvatarButton.bottomAnchor, constant: 10),
            
            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -100),
            
            saveGCDButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveGCDButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            saveGCDButton.heightAnchor.constraint(equalToConstant: 40),
            saveGCDButton.trailingAnchor.constraint(equalTo: saveOperationButton.leadingAnchor, constant: -10),
            saveGCDButton.widthAnchor.constraint(equalTo: saveOperationButton.widthAnchor),
            
            saveOperationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveOperationButton.bottomAnchor.constraint(equalTo: saveGCDButton.bottomAnchor),
            saveOperationButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: saveGCDButton.topAnchor, constant: -10),
            
            editTextButton.heightAnchor.constraint(equalToConstant: 40),
            editTextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editTextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: editTextButton.topAnchor, constant: -20)
        ])
        
    }
    
    //MARK: UIElements
    
    let navigationView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        return view
    }()
    
    let myProfileLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "My Profile"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let avatarImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black.withAlphaComponent(0.04)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let editAvatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let nameTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.placeholder = "Full name"
        textField.textAlignment = .center
        textField.textColor = .black
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        return textField
    }()
    
    let descriptionTextView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        textView.text = "Description"
        textView.isScrollEnabled = false
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    let editTextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let saveGCDButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Save GCD", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.alpha = 0.5
        return button
    }()
    
    let saveOperationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Save Operation", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.alpha = 0.5
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

//MARK: Lifecycle
extension ProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupUIActions()
        setupTheme()
        isEdit(isEdit: false)
        
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        readProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

}
//MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            oldImage = avatarImageView.image
            isEdit(isEdit: true)
            avatarImageView.image = image
            oldImageFlag = true
            showButtons(show: true)
        } else if let image = info[.editedImage] as? UIImage {
            oldImage = avatarImageView.image
            isEdit(isEdit: true)
            avatarImageView.image = image
            oldImageFlag = true
            showButtons(show: true)
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(hasChanges()) {
            print(#function)
            showButtons(show: true)
        } else {
            showButtons(show: false)
        }
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if(hasChanges()) {
            print(#function)
            showButtons(show: true)
        } else {
            showButtons(show: false)
        }
    }
}
