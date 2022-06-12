//
//  ViewController.swift
//  Journal App
//
//  Created by Shavkat Khoshimov on 04/06/22.
//

import UIKit

class NotesViewController: UIViewController {
    
    private var notesModel = NotesModel()
    private var notes = [Note]() {
        didSet {
            notes = notes.sorted(by: {$0.lastUpdatedAt > $1.lastUpdatedAt})
            self.tableView.reloadData()
        }
    }
    private let reuseId = "NoteCell"
    private var isStarFiltered = false
    
    var tableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        setStarFilterButtonImg()
        
        self.configureTableView()
        
        // Set self as the delegate for the notes model
        self.notesModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // retrieve all notes according to the filter status
        isStarFiltered ? self.notesModel.getNotes(true) : self.notesModel.getNotes()
    }
    
    func setStarFilterButtonImg() {
        let imageName = isStarFiltered ? "star.fill" : "star"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: imageName), style: .plain, target: self, action: #selector(filterBtnTapped))
    }

    
    private func configureTableView() {
        tableView.frame = self.view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        view.addSubview(tableView)
    }
    
    
    @objc func addTapped() {
        let destVC = DetailNoteVC()
        destVC.notesModel = self.notesModel
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @objc func filterBtnTapped() {
        isStarFiltered.toggle()
        isStarFiltered ? self.notesModel.getNotes(true) : self.notesModel.getNotes()
        setStarFilterButtonImg()
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "customCellColor")
        
        cell.textLabel?.text = notes[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        cell.detailTextLabel?.text = notes[indexPath.row].body
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.detailTextLabel?.numberOfLines = 2
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destVC = DetailNoteVC()
        destVC.notesModel = self.notesModel
        destVC.note = notes[indexPath.row]
        destVC.editMode = true
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notesModel.deleteNote(notes[indexPath.row])
            notes.remove(at: indexPath.row)
        }
    }
}


extension NotesViewController: NotesModelProtocol {
    func notesRetrieved(notes: [Note]) {
        // Set notes property and refresh the table view
        self.notes = notes
    }
}

