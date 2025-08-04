import UIKit

protocol Coordinator {
    func start()
}

class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let networkService = NetworkService()
        let viewModel = UsersListViewModel(networkService: networkService, followManager: UserDefaultsFollowManager())
        let usersVC = UsersListViewController(viewModel: viewModel)
        navigationController.viewControllers = [usersVC]
    }
}
