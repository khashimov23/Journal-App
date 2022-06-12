//
//  DetailNoteVC.swift
//  Journal App
//
//  Created by Shavkat Khoshimov on 04/06/22.
//

import UIKit

class DetailNoteVC: UIViewController, UITextViewDelegate {

    var rootStackView = UIStackView()
    var bottomStackView = UIStackView()
    var titleTextField = UITextField()
    var bodyTextView = UITextView()
    var saveButton = UIButton()
    var deleteButton = UIButton()
    var starButton = UIButton()
    var editMode = false
    
    var note: Note?
    var notesModel: NotesModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = editMode ? "Exist task" : "Add new"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnTapped))
        configureStyle()
        configureLayout()
        if self.note != nil {
            titleTextField.text = self.note?.title
            bodyTextView.text = self.note?.body
            setStarButtonImg()
        } else {
            // create new note
            let n = Note(docId: UUID().uuidString, title: titleTextField.text ?? "", body: bodyTextView.text ?? "", isStarred: false, createdAt: Date(), lastUpdatedAt: Date())
            self.note = n
        }
    }
    
    
    func setStarButtonImg() {
        let imageName = note!.isStarred ? "star.fill" : "star"
        starButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        note = nil
        titleTextField.text = nil
        bodyTextView.text = nil
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if bodyTextView.text == "placeholder..." {
            bodyTextView.text = nil
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if bodyTextView.text.isEmpty {
            bodyTextView.text = "placeholder..."
        }
    }
    
    
    @objc func starBtnTapped() {
        // change the property in the note
        note?.isStarred.toggle()
        notesModel?.updateStarStatus(note!.docId, note!.isStarred)
        setStarButtonImg()
    }
    
    @objc func deleteBtnTapped() {
        if self.note != nil {
            notesModel?.deleteNote(self.note!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func saveBtnTapped() {
        self.note?.title = titleTextField.text ?? ""
        self.note?.body  = bodyTextView.text ?? ""
        self.note?.lastUpdatedAt = Date()
        self.notesModel?.saveNote(self.note!)
        navigationController?.popViewController(animated: true)
    }
    
                                
    @objc func cancelBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func configureStyle() {
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        rootStackView.spacing = 20
        
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 40
        
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.masksToBounds = true
        deleteButton.contentMode = .scaleAspectFill
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
                
        saveButton.setTitle(editMode ? "Edit Task" : "Create Task", for: .normal)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.backgroundColor = editMode ? UIColor.systemRed : UIColor(named: "createTaskColor")
        saveButton.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        saveButton.contentMode = .scaleAspectFill
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        starButton.setImage(UIImage(systemName: "star"), for: .normal)
        starButton.addTarget(self, action: #selector(starBtnTapped), for: .touchUpInside)
        starButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.contentMode = .scaleAspectFill
        starButton.layer.cornerRadius = 10
        starButton.layer.masksToBounds = true
        starButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: titleTextField.bounds.height))
        titleTextField.leftView = paddingView
        titleTextField.leftViewMode = .always
        titleTextField.attributedPlaceholder = NSAttributedString(string:"title...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        titleTextField.autocorrectionType = .no
        titleTextField.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleTextField.backgroundColor = UIColor(named: "customCellColor")
    
        bodyTextView.text = "placeholder..."
        bodyTextView.autocorrectionType = .no
        bodyTextView.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        bodyTextView.layer.borderWidth = 5
        bodyTextView.layer.borderColor = UIColor(named: "customCellColor")?.cgColor
        bodyTextView.backgroundColor = UIColor(named: "customCellColor")
        bodyTextView.delegate = self
        
    }
    
    
    func configureLayout() {
        view.addSubview(rootStackView)
        rootStackView.addArrangedSubview(titleTextField)
        rootStackView.addArrangedSubview(bodyTextView)
        view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(deleteButton)
        bottomStackView.addArrangedSubview(saveButton)
        bottomStackView.addArrangedSubview(starButton)
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            rootStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            rootStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            rootStackView.heightAnchor.constraint(equalToConstant: 200),

            titleTextField.heightAnchor.constraint(equalToConstant: 60),
            bodyTextView.heightAnchor.constraint(equalToConstant: 140),

            bottomStackView.topAnchor.constraint(equalTo: rootStackView.bottomAnchor, constant: 50),
            bottomStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            bottomStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            bottomStackView.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
}
