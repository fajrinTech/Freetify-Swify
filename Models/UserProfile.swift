import Foundation

/// Model data profil pengguna Freetify
public struct UserProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var username: String
    public var avatarURL: URL?
    public var isPremium: Bool
    public var followersCount: Int
    public var followingCount: Int

    public init(
        id: String = UUID().uuidString,
        name: String,
        username: String,
        avatarURL: URL? = nil,
        isPremium: Bool = true,
        followersCount: Int = 128,
        followingCount: Int = 84
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.avatarURL = avatarURL
        self.isPremium = isPremium
        self.followersCount = followersCount
        self.followingCount = followingCount
    }

    public static let sample = UserProfile(
        name: "Fajrin",
        username: "@fajrin_music",
        avatarURL: URL(string: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80"),
        isPremium: true,
        followersCount: 240,
        followingCount: 156
    )
}
