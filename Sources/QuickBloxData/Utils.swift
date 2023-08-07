//
//  Utils.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

protocol Dated {
    var date: Date { get }
}

extension ComparisonResult {
    func inverted() -> ComparisonResult {
        switch self {
        case .orderedAscending:
            return .orderedDescending
        case .orderedDescending:
            return .orderedAscending
        case .orderedSame:
            return .orderedSame
        }
    }
}

extension Array where Element: Hashable {
    mutating func removeDuplicates() {
        var set = Set<Element>()
        var newArray = [Element]()
        
        for element in self {
            if !set.contains(element) {
                newArray.append(element)
                set.insert(element)
            }
        }
        
        self = newArray
    }
}

extension Array where Element: Dated, Element: Identifiable, Element: Hashable {
    mutating func insertElement(_ new: Element, withSorting order: ComparisonResult) {
        if isEmpty {
            append(new)
        } else {
            if let first = first, (new.date.compare(first.date) == order || new.date == first.date) {
                if new.date == first.date, new.id == first.id {
                    self[0] = new
                } else {
                    insert(new, at: 0)
                }
            } else if let last = last, (new.date.compare(last.date) == order.inverted() || new.date == last.date) {
                if new.date == last.date, new.id == last.id {
                    self[(count - 1)] = new
                } else {
                    append(new)
                }
            } else {
                let insertIndex = firstIndex { (new.date.compare($0.date) == order || new.date == $0.date) }
                if let index = insertIndex {
                    if new.date == self[index].date, self[index].id == new.id  {
                        self[index] = new
                    } else {
                        insert(new, at: index)
                    }
                } else {
                    append(new)
                }
            }
            self.removeDuplicates()
        }
    }
}

