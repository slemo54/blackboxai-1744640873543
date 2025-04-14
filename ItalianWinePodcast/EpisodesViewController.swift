import UIKit

class EpisodesViewController: UIViewController {
    private var episodes: [Episode] = []
    private let rssFeedURL = URL(string: "https://feeds.megaphone.fm/MJS8122694951")!
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(named: "BackgroundBeige")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchEpisodes()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadRequest(_:)),
            name: .downloadEpisodeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadProgress(_:)),
            name: .downloadProgress,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadComplete(_:)),
            name: .downloadCompleted,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDownloadRequest(_ notification: Notification) {
        guard let cell = notification.userInfo?["cell"] as? EpisodeCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let episode = episodes[indexPath.row]
        DownloadManager.shared.download(episode: episode)
        
        // Update cell to show download in progress
        cell.downloadButton.setTitle("0%", for: .normal)
        cell.downloadButton.isEnabled = false
    }
    
    @objc private func handleDownloadProgress(_ notification: Notification) {
        guard let episode = notification.userInfo?["episode"] as? Episode,
              let progress = notification.userInfo?["progress"] as? Float,
              let index = episodes.firstIndex(where: { $0.audioURL == episode.audioURL }),
              let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {
            return
        }
        
        let percent = Int(progress * 100)
        cell.downloadButton.setTitle("\(percent)%", for: .normal)
    }
    
    @objc private func handleDownloadComplete(_ notification: Notification) {
        guard let episode = notification.userInfo?["episode"] as? Episode,
              let index = episodes.firstIndex(where: { $0.audioURL == episode.audioURL }),
              let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {
            return
        }
        
        cell.downloadButton.setTitle("Downloaded", for: .normal)
        cell.downloadButton.isEnabled = false
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "BackgroundBeige")
        title = "Episodes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchEpisodes() {
        let session = URLSession.shared
        let task = session.dataTask(with: rssFeedURL) { [weak self] data, response, error in
            guard let self = self, let data = data else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let parser = RSSParser()
                let episodes = parser.parse(data: data)
                
                DispatchQueue.main.async {
                    self.episodes = episodes
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    private func downloadEpisode(at indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        DownloadManager.shared.download(episode: episode)
    }
}

extension EpisodesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.identifier, for: indexPath) as? EpisodeCell else {
            return UITableViewCell()
        }
        cell.configure(with: episodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        AudioPlayer.shared.play(episode: episode)
        
        // Show playback controls
        let alert = UIAlertController(
            title: "Now Playing",
            message: episode.title,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: AudioPlayer.shared.isPlaying ? "Pause" : "Play",
            style: .default
        ) { _ in
            AudioPlayer.shared.isPlaying ? AudioPlayer.shared.pause() : AudioPlayer.shared.play(episode: episode)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
