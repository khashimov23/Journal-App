//
//  NotesModel.swift
//  Journal App
//
//  Created by Shavkat Khoshimov on 04/06/22.
//

import Foundation
import Firebase


protocol NotesModelProtocol {
    func notesRetrieved(notes: [Note])
}

class NotesModel {
    
    var delegate: NotesModelProtocol?
    
    var listener: ListenerRegistration?
    
    deinit {
        // Unregister database listener
        listener?.remove()
    }
    
    func getNotes(_ starredOnly: Bool = false)   {
        
        // Detach any listener
        listener?.remove()
        
        // get a reference to the database
        let db = Firestore.firestore()
        
        var query: Query = db.collection("notes")
        
        if starredOnly {
            query = query.whereField("isStarred", isEqualTo: true)
        }
        
        // get all notes
        listener = query.addSnapshotListener { snapshot, error in
            
            if error == nil && snapshot != nil {
                var notes = [Note]()
                
                // parse documents into notes
                for doc in snapshot!.documents {
                    let createdAtDate: Date = Timestamp.dateValue(doc["createdAt"] as! Timestamp)()
                    let lastUpdatedAtDate: Date = Timestamp.dateValue(doc["lastUpdatedAt"] as! Timestamp)()
                    
                    let n = Note(docId: doc["docId"] as! String, title: doc["title"] as! String, body: doc["body"] as! String, isStarred: doc["isStarred"] as! Bool, createdAt: createdAtDate, lastUpdatedAt: lastUpdatedAtDate)
                    notes.append(n)
                }
                
                // Call the delegate and pass back the notes via Main thread
                DispatchQueue.main.async {
                    self.delegate?.notesRetrieved(notes: notes)
                }
            }
        }
    }
    
    
    func deleteNote(_ n: Note) {
        let db = Firestore.firestore()
        db.collection("notes").document(n.docId).delete()
    }
    
    
    func saveNote(_ n: Note) {
        let db = Firestore.firestore()
        db.collection("notes").document(n.docId).setData(noteToDict(n))
    }
    
    
    func updateStarStatus(_ docId: String, _ isStarred: Bool) {
        let db = Firestore.firestore()
        db.collection("notes").document(docId).updateData(["isStarred": isStarred])
    }
    
    func noteToDict(_ n: Note) -> [String: Any] {
        var dict = [String: Any]()
        dict["title"] = n.title
        dict["docId"] = n.docId
        dict["body"] = n.body
        dict["createdAt"] = n.createdAt
        dict["isStarred"] = n.isStarred
        dict["lastUpdatedAt"] = n.lastUpdatedAt
        
        return dict
    }
}
