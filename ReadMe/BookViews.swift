//
//  BookViews.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

import SwiftUI

struct TitleAndAuthorStack: View {
    let book: Book
    let titleFont: Font
    let authorFont: Font
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
                .font(titleFont)
            Text(book.author)
                .font(authorFont)
                .foregroundColor(.secondary)
        }
    }
}

extension Book {
    struct Image: View {
        let title: String
        var size: CGFloat?
        
        var body: some View {
            let symbol = SwiftUI.Image(title: title) ?? .init(systemName: "book")
            
            symbol
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .font(Font.title.weight(.light))
                .foregroundColor(.secondary)
        }
    }
}

struct Book_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            TitleAndAuthorStack(book: .init(), titleFont: .title, authorFont: .title2)
            Book.Image(title: Book().title)
            Book.Image(title: "Book2")
            Book.Image(title: "Book1")
        }
        .previewedInAllCollorScheems
    }
}

extension Image {
    init?(title: String) {
        guard
            let character = title.first,
            case let symbolName = "\(character.lowercased()).square",
            UIImage(systemName: symbolName) != nil else {
            return nil
        }
        
        self.init(systemName: symbolName)
    }
}

extension View {
    var previewedInAllCollorScheems: some View {
        ForEach(ColorScheme.allCases, id: \.self, content: preferredColorScheme)
    }
}
