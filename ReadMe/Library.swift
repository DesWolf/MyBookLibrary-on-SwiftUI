//
//  Library.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//
import Combine
import class UIKit.UIImage

enum Section: CaseIterable {
    case readMe
    case finished
}

final class Library: ObservableObject {
    var sortedBooks: [Book] { booksCache }
    
    var manuallySortedBooks: [Section: [Book]] {
        Dictionary(grouping: booksCache, by: \.readMe)
            .mapKeys(Section.init)
    }
    
    func addNewBook(_ book: Book, image: UIImage?) {
        booksCache.insert(book, at: 0)
        uiImages[book] = image
        storeCancellable(for: book)
    }
    
    @Published var uiImages: [Book: UIImage] = [:]
    
    init() {
        booksCache.forEach(storeCancellable)
    }
    
    @Published private var booksCache: [Book] = [
      .init(title: "Ein Neues Land", author: "Shaun Tan"),
      .init(title: "Bosch", author: "Laurinda Dixon", microReview: "Earthily Delightful."),
      .init(title: "Dare to Lead", author: "Brené Brown"),
      .init(title: "Blasting for Optimum Health Recipe Book", author: "NutriBullet", microReview: "Blastastic!"),
      .init(title: "Drinking with the Saints", author: "Michael P. Foley"),
      .init(title: "A Guide to Tea", author: "Adagio Teas"),
      .init(title: "The Life and Complete Work of Francisco Goya", author: "P. Gassier & J Wilson"),
      .init(title: "Lady Cottington's Pressed Fairy Book", author: "Lady Cottington"),
      .init(title: "How to Draw Cats", author: "Janet Rancan"),
      .init(title: "Drawing People", author: "Barbara Bradley"),
      .init(title: "What to Say When You Talk to Yourself", author: "Shad Helmstetter")
    ]
    
    private var cancellabales: Set<AnyCancellable> = []
}
//MARK: - private
private extension Library {
    func storeCancellable(for book: Book) {
        book.$readMe.sink { [unowned self] _ in
            objectWillChange.send()
        }
        .store(in: &cancellabales)
    }
}
private extension Section {
    init(readMe: Bool) {
        self = readMe ? .readMe : .finished
    }
}

private extension Dictionary {
  func mapKeys<Transformed>(
    _ transform: (Key) throws -> Transformed
  ) rethrows -> [Transformed: Value] {
    .init(
      uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
    )
  }
}
