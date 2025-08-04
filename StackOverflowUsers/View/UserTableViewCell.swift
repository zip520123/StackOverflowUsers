import UIKit

class UserTableViewCell: UITableViewCell {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let reputationLabel = UILabel()
    private let followButton = UIButton(type: .system)
    private let followedIndicator = UIImageView()
    
    var followAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profileImageView)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        reputationLabel.font = UIFont.systemFont(ofSize: 14)
        reputationLabel.textColor = .gray
        reputationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reputationLabel)
        
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        contentView.addSubview(followButton)
        
        followedIndicator.translatesAutoresizingMaskIntoConstraints = false
        followedIndicator.image = UIImage(systemName: "star.fill")
        followedIndicator.tintColor = .systemYellow
        contentView.addSubview(followedIndicator)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: followButton.leadingAnchor, constant: -8),
            
            reputationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            reputationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            reputationLabel.trailingAnchor.constraint(lessThanOrEqualTo: followButton.leadingAnchor, constant: -8),
            
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            followedIndicator.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),
            followedIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followedIndicator.widthAnchor.constraint(equalToConstant: 20),
            followedIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with user: User, isFollowing: Bool) {
        nameLabel.text = user.display_name
        reputationLabel.text = "Reputation: \(user.reputation)"
        followButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        followedIndicator.isHidden = !isFollowing
        if let urlString = user.profile_image, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
    
    @objc private func followButtonTapped() {
        followAction?()
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
}
