import AVFoundation

class AudioPlayer: NSObject {
    static let shared = AudioPlayer()
    
    private var player: AVPlayer?
    private var currentEpisode: Episode?
    private var timeObserverToken: Any?
    
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    var currentTime: CMTime {
        return player?.currentTime() ?? .zero
    }
    
    var duration: CMTime {
        return player?.currentItem?.asset.duration ?? .zero
    }
    
    func play(episode: Episode) {
        guard let audioURL = episode.audioURL else { return }
        
        if currentEpisode?.audioURL != audioURL {
            currentEpisode = episode
            player = AVPlayer(url: audioURL)
            setupNowPlayingInfo(for: episode)
            setupRemoteCommandCenter()
        }
        
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    private func setupNowPlayingInfo(for episode: Episode) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Italian Wine Podcast"
        
        if let imageURL = episode.imageURL {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = 
                        MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }.resume()
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.player?.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 1))
            return .success
        }
    }
    
    func addPeriodicTimeObserver(interval: CMTime, queue: DispatchQueue, using block: @escaping (CMTime) -> Void) {
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: block)
    }
    
    func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
}
