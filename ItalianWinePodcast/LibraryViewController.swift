import UIKit

class LibraryViewController: UIViewController {
    private var downloadedEpisodes: [Episode] = []
    
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
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "square.stack"))
        imageView.tintColor = UIColor(named: "Gold")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No downloaded episodes"
        label.textColor = UIColor(named: "Bordeaux")
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDownloads()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "BackgroundBeige")
        title = "Library"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadDownloads() {
        downloadedEpisodes = Episode.loadDownloadedEpisodes()
        emptyStateView.isHidden = !downloadedEpisodes.isEmpty
        tableView.reloadData()
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.identifier, for: indexPath) as? EpisodeCell else {
            return UITableViewCell()
        }
        cell.configure(with: downloadedEpisodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = downloadedEpisodes[indexPath.row]
        AudioPlayer.shared.play(episode: episode)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let episode = downloadedEpisodes[indexPath.row]
            
            // Delete local file
            if let filePath = episode.localFilePath {
                try? FileManager.default.removeItem(at: filePath)
            }
            
            // Remove from data source
            downloadedEpisodes.remove(at: indexPath.row)
            Episode.saveDownloadedEpisodes(downloadedEpisodes)
            
            // Update UI
            tableView.deleteRows(at: [indexPath], with: .automatic)
            emptyStateView.isHidden = !downloadedEpisodes.isEmpty
        }
    }
}
