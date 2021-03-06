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
                
                switch library.sortStyle {
                case .title, .author:
                    BookRows(data: library.sortedBooks, section: nil)
                case .manual:
                    ForEach(Section.allCases, id: \.self) {
                        SectionView(section: $0)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Sort") {
                        Picker("Sort Style", selection: $library.sortStyle) {
                            ForEach(SortStyle.allCases, id: \.self) { sortStyle in
                                Text("\(sortStyle)".capitalized)
                            }
                        }
                    }
                }
                ToolbarItem(content: EditButton.init)
            }
            .navigationBarTitle("My library")
        }
    }
}

private struct BookRows: DynamicViewContent {
    let data: [Book]
    let section: Section?
    @EnvironmentObject var library: Library
    
    var body: some View {
        ForEach(data) {
            BookRow(book: $0)
        }
        .onDelete { indexSet in
            library.deleteBooks(atOffSets: indexSet, section: section)
        }
    }
}


private struct BookRow: View {
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

private struct SectionView: View {
    let section: Section
    @EnvironmentObject var library: Library
    
    var title: String {
        switch section {
        case .readMe:
            return "Read Me!"
        case .finished:
            return "Finished!"
        }
    }
    
    var body: some View {
        if let books = library.manuallySortedBooks[section] {
            SwiftUI.Section(
                header: ZStack {
                    Image("BookTexture")
                        .resizable()
                        .scaledToFit()
                    Text(title)
                        .font(.custom("American Typewriter", size: 24))
                }
                .listRowInsets(.init())
            ) {
                BookRows(data: books, section: section)
                    .onMove { indices, newOffset in
                        library.moveBooks(oldOffset: indices, newOffset: newOffset, section: section)
                    }
                    .moveDisabled(section == .none)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Library())
            .previewedInAllColorScheems
        
    }
}
