import Foundation

/// Model data lagu Freetify
public struct Track: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let artworkURL: URL?
    public let audioURL: URL
    public let duration: TimeInterval
    public var lyricsLRC: String?
    public var isFavorite: Bool
    public var artistHeroURL: URL?
    public var artistBio: String?
    public var supabaseId: String?
    public var cachedLocalAudioURL: URL?

    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        album: String,
        artworkURL: URL? = nil,
        audioURL: URL,
        duration: TimeInterval,
        lyricsLRC: String? = nil,
        isFavorite: Bool = false,
        artistHeroURL: URL? = nil,
        artistBio: String? = nil,
        supabaseId: String? = nil,
        cachedLocalAudioURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkURL = artworkURL
        self.audioURL = audioURL
        self.duration = duration
        self.lyricsLRC = lyricsLRC
        self.isFavorite = isFavorite
        self.artistHeroURL = artistHeroURL
        self.artistBio = artistBio
        self.supabaseId = supabaseId
        self.cachedLocalAudioURL = cachedLocalAudioURL
    }
}

// MARK: - Mock / Sample Tracks untuk Demo & Testing
extension Track {
    public static let samples: [Track] = [
        Track(
            id: "track-1",
            title: "Sialan",
            artist: "Juicy Luicy, Adrian Khalif",
            album: "Nonfiksi",
            artworkURL: URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80"),
            audioURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!,
            duration: 218.0,
            lyricsLRC: """
            [00:00.00]Juicy Luicy, Adrian Khalif - Sialan
            [00:06.00]Dari jendela ku menatap langit kelabu
            [00:12.50]Bayangmu perlahan datang mengetuk kalbu
            [00:19.00]Mengapa harus di tempat ini kita bertemu?
            [00:25.00]Saat ku sudah mulai melupakanmu
            [00:31.00]Sialan, kau buat ku jatuh cinta lagi
            [00:37.50]Di saat ku berusaha menjaga hati
            [00:44.00]Tatapan matamu masih sama seperti dulu
            [00:50.50]Membuatku terpaku tak mampu membisu
            [00:58.00]Haruskah kita mengulang kisah lama?
            [01:05.00]Atau sekadar menyapa lalu berpura-pura lupa
            """,
            isFavorite: true,
            artistHeroURL: URL(string: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1200&q=80"),
            artistBio: "Juicy Luicy adalah grup musik asal Bandung yang dibentuk pada tahun 2010. Musik mereka menggabungkan elemen pop dan akustik dengan lirik romantis yang relate dengan kehidupan sehari-hari."
        ),
        Track(
            id: "track-2",
            title: "Gala Bunga Matahari",
            artist: "Sal Priadi",
            album: "MARKERS AND SUCH PENS FLASHDISKS",
            artworkURL: URL(string: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80"),
            audioURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")!,
            duration: 245.0,
            lyricsLRC: """
            [00:00.00]Sal Priadi - Gala Bunga Matahari
            [00:08.00]Mungkinkah kau ada di sana?
            [00:15.00]Terbang bebas di antara awan dan mega
            [00:23.00]Bila kau rindu, petiklah sekuntum bunga
            [00:32.00]Kirimkan harumnya lewat hembusan udara
            [00:41.00]Kini ku bernyanyi sendiri di taman sepi
            [00:50.00]Menanti senyuman yang abadi di dalam mimpi
            """,
            isFavorite: false,
            artistHeroURL: URL(string: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=1200&q=80"),
            artistBio: "Salmantyo Ashrizky Priadi atau lebih dikenal dengan Sal Priadi adalah seorang penyanyi, penulis lagu, dan aktor asal Malang, Indonesia."
        ),
        Track(
            id: "track-3",
            title: "Boleh Juga",
            artist: "Salma Salsabil",
            album: "Boleh Juga - Single",
            artworkURL: URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80"),
            audioURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3")!,
            duration: 198.0,
            lyricsLRC: """
            [00:00.00]Salma Salsabil - Boleh Juga
            [00:05.00]Ada getar yang berbeda saat kau menyapa
            [00:11.00]Tak biasanya hati ini berdebar merona
            [00:18.00]Boleh juga caramu meluluhkan egoku
            [00:25.00]Hingga ku tak kuasa menahan senyum untukmu
            """,
            isFavorite: true,
            artistHeroURL: URL(string: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200&q=80"),
            artistBio: "Salma Salsabil 'Aliyyah Putri Mandaya adalah pemenang Indonesian Idol musim kedua belas yang memukau dengan vokal jazzy dan aransemen khasnya."
        )
    ]
}
