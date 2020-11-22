//
//  Library.swift
//  ReadMe
//
//  Created by Максим Окунеев on 11/7/20.
//

import Combine
import Foundation
import struct SwiftUI.PreviewDevice
import class UIKit.UIImage

enum Section: CaseIterable {
  case readMe
  case finished
}

final class Library: ObservableObject {
  var sortedBooks: [Book] {
    get { booksCache }
    set {
        booksCache.removeAll { book in
            !newValue.contains(book)
        }
    }
  }
    
  var manuallySortedBooks: [Section: [Book]] {
    get {
    Dictionary(grouping: booksCache, by: \.readMe)
      .mapKeys(Section.init)
    } set {
        newValue
            .sorted { $1.key == .finished }
        booksCache = newValue.flatMap { $0.value }
    }
  }

  /// Adds a new book at the start of the library's manually-sorted books.
  func addNewBook(_ book: Book, image: UIImage?) {
    booksCache.insert(book, at: 0)
    uiImages[book] = image
    storeCancellables(for: book)
  }
    
    func deleteBooks(atOffSets offsets: IndexSet, section: Section?) {
        let bookBeforeDeletion = booksCache
        if let section = section {
            manuallySortedBooks[section]?.remove(atOffsets: offsets)
        } else {
            sortedBooks.remove(atOffsets: offsets)
        }
        for change in booksCache.difference(from: bookBeforeDeletion) {
            if case .remove(_, let deletedBook, _) = change {
                uiImages[deletedBook] = nil
            }
        }
    }

    func moveBooks(oldOffset: IndexSet, newOffset: Int, section: Section) {
        manuallySortedBooks[section]?.move(fromOffsets: oldOffset, toOffset: newOffset)
    }
    
  /// Load, save, or delete an image corresponding to a book's title and author.
  var uiImages: ObjectSubscript<Library, Book, UIImage?> {
    get {
      .init(
        self,
        get: { library in
          { book in
            if let image = library.uiImagesCache[book] {
              return image
            } else if let image = UIImage(contentsOfFile: book.imageURL.path) {
              library.uiImagesCache[book] = image
              return image
            } else {
              return nil
            }
          }
        },
        set: { library, book, newValue in
          library.uiImagesCache[book] = newValue

          DispatchQueue.global().async {
            if let newValue = newValue {
              try? newValue.jpegData(compressionQuality: 0.7)?.write(
                to: book.imageURL,
                options: .atomicWrite
              )
            } else {
              try? FileManager.default.removeItem(at: book.imageURL)
            }
          }
        }
      )
    }
    set {
      // `EnvironmentObject.Wrapper[dynamicMember:]`
      // only works with `ReferenceWritableKeyPath`s,
      // so this has to seem like it's writable.
    }
  }

  init() {
    booksCache.forEach(storeCancellables)
  }

  /// An in-memory cache of the manually-sorted books that are persistently stored.
  @Published private var booksCache: [Book] =
  (
    try? JSONDecoder().decode(
      [Book].self, from: .init(contentsOf: .jsonURL)
    )
  ).filter { _ in !PreviewDevice.inXcode }
  ??
  [ .init(title: "Ein Neues Land", author: "Shaun Tan"),
    .init( title: "Bosch", author: "Laurinda Dixon", microReview: "Earthily Delightful."),
    .init(title: "Dare to Lead", author: "Brené Brown"),
    .init( title: "Blasting for Optimum Health Recipe Book", author: "NutriBullet", microReview: "Blastastic!"),
    .init(title: "Drinking with the Saints", author: "Michael P. Foley"),
    .init(title: "A Guide to Tea", author: "Adagio Teas"),
    .init(title: "The Life and Complete Work of Francisco Goya", author: "P. Gassier & J Wilson"),
    .init(title: "Lady Cottington's Pressed Fairy Book", author: "Lady Cottington"),
    .init(title: "How to Draw Cats", author: "Janet Rancan"),
    .init(title: "Drawing People", author: "Barbara Bradley"),
    .init(title: "What to Say When You Talk to Yourself", author: "Shad Helmstetter")
  ]
  {
    didSet { saveBooks() }
  }

  /// An in-memory cache for books that have persistently stored images.
  @Published private var uiImagesCache: [Book: UIImage] = [:]

  /// Forwards individual book changes to be considered Library changes.
  private var cancellables: Set<AnyCancellable> = []
}

// MARK: - internal

/// An emulation of the missing Swift feature of named subscripts.
/// - Note: Argument labels are not supported.
struct ObjectSubscript<Object: AnyObject, Index, Value> {
  public typealias Get = (Object) -> (Index) -> Value
  public typealias Set = (Object, Index, Value) -> Void

  public var object: Object
  public var get: Get
  public var set: Set
}

extension ObjectSubscript {
  init(
    _ object: Object,
    get: @escaping Get,
    set: @escaping Set
  ) {
    self.object = object
    self.get = get
    self.set = set
  }

  subscript(index: Index) -> Value {
    get { get(object)(index) }
    nonmutating set { set(object, index, newValue) }
  }
}

// MARK: - private
private extension Library {
  func saveBooks() {
    DispatchQueue.global().async { [booksCache] in
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      try? encoder.encode(booksCache).write(to: .jsonURL, options: .atomicWrite)
    }
  }

  func storeCancellables(for book: Book) {
    cancellables.formUnion([
      book.$readMe.sink { [unowned self] _ in
        objectWillChange.send()
        saveBooks()
      },
      book.$microReview.sink { [unowned self] _ in
        saveBooks()
      }
    ])
  }
}

private extension Book {
  var imageURL: URL {
    .init(
      fileName: "\(title) by \(author)",
      extension: "jpeg"
    )
  }
}

private extension Section {
  init(readMe: Bool) {
    self = readMe ? .readMe : .finished
  }
}

private extension Dictionary {
  /// Same values, corresponding to `map`ped keys.
  ///
  /// - Parameter transform: Accepts each key of the dictionary as its parameter
  ///   and returns a key for the new dictionary.
  /// - Postcondition: The collection of transformed keys must not contain duplicates.
  func mapKeys<Transformed>(
    _ transform: (Key) throws -> Transformed
  ) rethrows -> [Transformed: Value] {
    .init(
      uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
    )
  }
}

private extension Optional {
  /// Transform `.some` into `.none`, if a condition fails.
  /// - Parameters:
  ///   - isSome: The condition that will result in `nil`, when evaluated to `false`.
  func filter(_ isSome: (Wrapped) throws -> Bool) rethrows -> Self {
    try flatMap { try isSome($0) ? $0 : nil }
  }
}

private extension PreviewDevice {
  /// Whether this code is running in a SwiftUI preview.
  static var inXcode: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
}

private extension URL {
  static let jsonURL = Self(fileName: "Books", extension: "json")

  init(fileName: String, extension: String) {
    self =
      FileManager.`default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(fileName)
      .appendingPathExtension(`extension`)
  }
}

// MARK: - Published: Codable

import struct Combine.Published

extension Published: Codable where Value: Codable {
  public func encode(to encoder: Encoder) throws {
    guard
      let storageValue =
        Mirror(reflecting: self).descendant("storage")
        .map(Mirror.init)?.children.first?.value,
      let value =
        storageValue as? Value
        ?? ((storageValue as? Publisher).map { publisher in
          Mirror(reflecting: publisher).descendant("subject", "currentValue")
        }) as? Value
    else { throw EncodingError.invalidValue(self, codingPath: encoder.codingPath) }

    try value.encode(to: encoder)
  }

  public init(from decoder: Decoder) throws {
    self.init(
      initialValue: try .init(from: decoder)
    )
  }
}

private extension EncodingError {
  /// `invalidValue` without having to pass a `Context` as an argument.
  static func invalidValue(
    _ value: Any,
    codingPath: [CodingKey],
    debugDescription: String = .init()
  ) -> Self {
    .invalidValue(
      value,
      .init(
        codingPath: codingPath,
        debugDescription: debugDescription
      )
    )
  }
}

