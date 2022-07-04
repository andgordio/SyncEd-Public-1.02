//
//  SessionPageInputViewController.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/7/22.
//

import SwiftUI
import FirebaseFirestore

class SessionPageInputViewController: ObservableObject {
    
    var ref: DocumentReference? = nil
    
    @Published var textinput = ""
    var whatIjustSent = ""
    var whatIjustGot = ""
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    func initViewModel(sessionId: String, taksId: String) {
        let db = Firestore.firestore()
        let path = db.collection("sessions").document(sessionId).collection("inputs").document(taksId)
        self.ref = path
        path.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                path.setData([
                    "body" : ""
                ])
                return
            }
            let pulledInput = data["body"] as? String ?? ""
            if pulledInput != self.whatIjustSent {
                self.textinput = pulledInput
                self.whatIjustGot = pulledInput
            }
        }
    }
    
    func pushUpdates() {
        let frozenInput = textinput
        if frozenInput == whatIjustSent || frozenInput == whatIjustGot {
            return
        } else {
            self.whatIjustSent = frozenInput
            if let ref = ref {
                ref.setData(["body" : frozenInput], merge: true)
            }
        }
        
    }
    
    
}
