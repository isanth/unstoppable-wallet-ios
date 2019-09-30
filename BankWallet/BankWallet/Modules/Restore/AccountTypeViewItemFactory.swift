class AccountTypeViewItemFactory {

    func viewItems(accountTypes: [IPredefinedAccountType]) -> [AccountTypeViewItem] {
        return accountTypes.map { AccountTypeViewItem(title: $0.title, coinCodes: $0.coinCodes) }
    }

}
