class RestoreInteractor {
    weak var delegate: IRestoreInteractorDelegate?

    private let accountManager: IAccountManager
    private let accountFactory = AccountFactory()

    init(accountManager: IAccountManager) {
        self.accountManager = accountManager
    }
}

extension RestoreInteractor: IRestoreInteractor {

    var allTypes: [PredefinedAccountType] {
        return PredefinedAccountType.allCases
    }

}

extension RestoreInteractor: IRestoreDelegate {

    func didRestore(accountType: AccountType, syncMode: SyncMode?) {
        let account = accountFactory.account(
                type: accountType,
                backedUp: true,
                defaultSyncMode: syncMode
        )

        accountManager.save(account: account)

        delegate?.didRestore()
    }

}
