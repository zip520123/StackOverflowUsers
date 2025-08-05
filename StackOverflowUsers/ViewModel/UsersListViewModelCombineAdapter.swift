import Foundation
import Combine

class UsersListViewModelCombineAdapter {
    private let viewModel: UsersListViewModel

    let usersPublisher: AnyPublisher<[User], Never>
    let errorPublisher: AnyPublisher<Error?, Never>

    private let usersSubject: CurrentValueSubject<[User], Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
        self.usersSubject = CurrentValueSubject(viewModel.users)
        self.errorSubject = CurrentValueSubject(nil)

        self.usersPublisher = usersSubject.eraseToAnyPublisher()
        self.errorPublisher = errorSubject.eraseToAnyPublisher()

        viewModel.onUsersUpdated = { [weak self] in
            self?.usersSubject.send(viewModel.users)
        }
        viewModel.onError = { [weak self] error in
            self?.errorSubject.send(error)
        }
    }
}
