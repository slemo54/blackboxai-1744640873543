import Foundation

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.italianwinepodcast.downloads")
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private var activeDownloads: [URL: Download] = [:]
    
    struct Download {
        let episode: Episode
        let task: URLSessionDownloadTask
        var progress: Float = 0
    }
    
    func download(episode: Episode) {
        guard let audioURL = episode.audioURL else { return }
        
        if activeDownloads[audioURL] != nil {
            // Already downloading
            return
        }
        
        let task = urlSession.downloadTask(with: audioURL)
        activeDownloads[audioURL] = Download(episode: episode, task: task)
        task.resume()
        
        NotificationCenter.default.post(
            name: .downloadStarted,
            object: nil,
            userInfo: ["episode": episode]
        )
    }
    
    func cancelDownload(for episode: Episode) {
        guard let audioURL = episode.audioURL,
              let download = activeDownloads[audioURL] else { return }
        
        download.task.cancel()
        activeDownloads.removeValue(forKey: audioURL)
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
              var download = activeDownloads[url] else { return }
        
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        activeDownloads[url] = download
        
        NotificationCenter.default.post(
            name: .downloadProgress,
            object: nil,
            userInfo: [
                "episode": download.episode,
                "progress": download.progress
            ]
        )
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url,
              let download = activeDownloads[url] else { return }
        
        activeDownloads.removeValue(forKey: url)
        
        // Move file to documents directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        do {
            try fileManager.moveItem(at: location, to: destinationURL)
            NotificationCenter.default.post(
                name: .downloadCompleted,
                object: nil,
                userInfo: [
                    "episode": download.episode,
                    "localURL": destinationURL
                ]
            )
        } catch {
            NotificationCenter.default.post(
                name: .downloadFailed,
                object: nil,
                userInfo: [
                    "episode": download.episode,
                    "error": error
                ]
            )
        }
    }
}

extension Notification.Name {
    static let downloadStarted = Notification.Name("downloadStarted")
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadCompleted = Notification.Name("downloadCompleted")
    static let downloadFailed = Notification.Name("downloadFailed")
}
