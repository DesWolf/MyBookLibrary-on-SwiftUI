//
//  BookViews.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

import SwiftUI

struct BookmarkButton: View {
    @ObservedObject var book: Book
    var body: some View {
        let bookmark = "bookmark"
        
        Button {
            book.readMe.toggle()
        } label: {
            Image(systemName: book.readMe ? "\(bookmark).fill" : bookmark)
                .font(.system(size: 48, weight: .light))
        }
    }
}


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
        let uiImage: UIImage?
        let cornerRadius: CGFloat
        
        var body: some View {
            if let image = uiImage.map(SwiftUI.Image.init) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .cornerRadius(cornerRadius)
            } else {
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
}

struct Book_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                BookmarkButton(book: .init())
                BookmarkButton(book: .init(readMe: false))
                TitleAndAuthorStack(book: .init(), titleFont: .title, authorFont: .title2)
            }
                Book.Image(title: Book().title)
                Book.Image(title: "Book2")
                Book.Image(title: "Book1")
            }
            .previewedInAllColorScheems
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

extension Book.Image {
    // Preview Image
    init(title: String) {
        self.init(title: title, uiImage: nil, cornerRadius: .init())
    }
}

extension View {
    var previewedInAllColorScheems: some View {
        ForEach(ColorScheme.allCases, id: \.self, content: preferredColorScheme)
    }
}
