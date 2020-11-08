//
//  ContentView.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

import SwiftUI

struct ContentView: View {
    @State var addingNewBook = false
    @EnvironmentObject var library: Library
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    addingNewBook = true
                } label: {
                    Spacer()
                    VStack(alignment: .center, spacing: 6) {
                        Image(systemName: "book.circle")
                            .font(.system(size: 60))
                        Text("Add New Book")
                            .font(.title)
                    }
                    Spacer()
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.vertical, 8)
                .sheet(isPresented: $addingNewBook, content: NewBookView.init)
                ForEach(library.sortedBooks) { book in
                    BookRow(book: book)
                }
            }
            .navigationTitle("My library")
        }
    }
}

struct BookRow: View {
    @ObservedObject var book: Book
    @EnvironmentObject var library: Library
    
    var body: some View {
        NavigationLink(
            destination: DetailView(book: book)) {
            HStack {
                Book.Image(title: book.title, size: 80, uiImage: library.uiImages[book], cornerRadius: 12)
                VStack(alignment: .leading) {
                    TitleAndAuthorStack(book: book, titleFont: .title2, authorFont: .title3)
                    
                    if !book.microReview.isEmpty {
                        Spacer()
                        Text(book.microReview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                    .lineLimit(1)
                Spacer()
                BookmarkButton(book: book)
                    .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.vertical, 8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Library())
            .previewedInAllCollorScheems

    }
}
