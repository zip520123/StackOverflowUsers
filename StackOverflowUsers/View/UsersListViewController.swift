import UIKit
import Combine

class UsersListViewController: UIViewController {
    private let viewModel: UsersListViewModel
    private let combineAdapter: UsersListViewModelCombineAdapter
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView()
    private let errorLabel = UILabel()
    
    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        self.combineAdapter = UsersListViewModelCombineAdapter(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchUsers()
    }
    
    private func bindViewModel() {
        combineAdapter.usersPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.hideError()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        combineAdapter.errorPublisher
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showError(error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "StackOverflow Users"
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        errorLabel.textAlignment = .center
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideError() {
        errorLabel.isHidden = true
        tableView.isHidden = false
    }
}

extension UsersListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = viewModel.users[indexPath.row]
        let isFollowing = viewModel.isFollowing(user: user)
        cell.configure(with: user, isFollowing: isFollowing)
        cell.followAction = { [weak self] in
            if isFollowing {
                self?.viewModel.unfollow(user: user)
            } else {
                self?.viewModel.follow(user: user)
            }
        }
        return cell
    }
}
