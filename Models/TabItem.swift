import Foundation
import SwiftUI

/// Item tab navigasi utama aplikasi Freetify
public enum TabItem: Int, CaseIterable, Identifiable, Sendable {
    case home = 0
    case search = 1
    case library = 2

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .home: return "Beranda"
        case .search: return "Cari"
        case .library: return "Koleksi"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical"
        }
    }

    public var activeIcon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        }
    }
}
