import UIKit

extension Notification.Name {
    static let downloadEpisodeNotification = Notification.Name("downloadEpisodeNotification")
}

class EpisodeCell: UITableViewCell {
    static let identifier = "EpisodeCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor(named: "Bordeaux")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor(named: "Gold")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.setTitleColor(UIColor(named: "Gold"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(named: "BackgroundBeige")
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let rightStack = UIStackView(arrangedSubviews: [durationLabel, downloadButton])
        rightStack.axis = .vertical
        rightStack.spacing = 8
        rightStack.alignment = .trailing
        
        let mainStack = UIStackView(arrangedSubviews: [textStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            downloadButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    @objc private func downloadButtonTapped() {
        NotificationCenter.default.post(
            name: .downloadEpisodeNotification,
            object: nil,
            userInfo: ["cell": self]
        )
    }
    
    func configure(with episode: Episode) {
        titleLabel.text = episode.title
        dateLabel.text = episode.formattedDate
        durationLabel.text = episode.duration
        descriptionLabel.text = episode.description
    }
}
