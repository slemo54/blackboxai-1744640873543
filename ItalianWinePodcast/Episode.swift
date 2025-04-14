import Foundation

struct Episode: Codable {
    let title: String
    let description: String
    let pubDate: Date
    let duration: String
    let imageURL: URL?
    let audioURL: URL?
    var localFilePath: URL?
    var isDownloaded: Bool {
        guard let path = localFilePath else { return false }
        return FileManager.default.fileExists(atPath: path.path)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: pubDate)
    }
    
    static func saveDownloadedEpisodes(_ episodes: [Episode]) {
        let encoder = PropertyListEncoder()
        if let encoded = try? encoder.encode(episodes) {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("downloadedEpisodes.plist")
            try? encoded.write(to: fileURL)
        }
    }
    
    static func loadDownloadedEpisodes() -> [Episode] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("downloadedEpisodes.plist")
        
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = PropertyListDecoder()
        return (try? decoder.decode([Episode].self, from: data)) ?? []
    }
}
