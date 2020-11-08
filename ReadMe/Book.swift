//
//  Book.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

struct Book: Hashable {
    let title: String
    let author: String
    
    init(title: String = "Title", author: String = "Author") {
        self.title = title
        self.author = author
    }
}
