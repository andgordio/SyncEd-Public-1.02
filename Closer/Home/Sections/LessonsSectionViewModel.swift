//
//  LessonsSectionViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI
import FirebaseFirestore

class LessonsSectionViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    @Published var lessons: [Lesson] = []
    
    func loadLessons(for level: LessonLevel) {
        if !lessons.isEmpty {
            return
        }
        db.collection("lessons")
            .whereField("level", isEqualTo: level.rawValue)
        #if !DEBUG
            .whereField("isPublished", isEqualTo: true)
        #endif
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard let snapshot = snapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documents.forEach { document in
                        let lesson = Lesson(
                            uid: document.documentID,
                            name: document.data()["name"] as? String ?? "Unnamed lesson",
                            description: document.data()["description"] as? String ?? "",
                            level: LessonLevel(rawValue: document.data()["level"] as? String ?? "beginner") ?? LessonLevel.beginner
                        )
                        self.lessons.append(lesson)
                    }
                }
            }
    }
    
}
