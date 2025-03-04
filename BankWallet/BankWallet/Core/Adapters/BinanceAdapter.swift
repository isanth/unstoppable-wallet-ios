import RxSwift
import BinanceChainKit

class BinanceAdapter {
    static let transferFee: Decimal = 0.000375

    private let binanceKit: BinanceChainKit
    private let asset: Asset

    init(binanceKit: BinanceChainKit, symbol: String) {
        self.binanceKit = binanceKit

        asset = binanceKit.register(symbol: symbol)
    }

    private func transactionRecord(fromTransaction transaction: TransactionInfo) -> TransactionRecord {
        let from = TransactionAddress(
                address: transaction.from,
                mine: transaction.from == binanceKit.account
        )

        let to = TransactionAddress(
                address: transaction.to,
                mine: transaction.to == binanceKit.account
        )

        var amount: Decimal = 0
        if from.mine {
            amount -= transaction.amount
        }
        if to.mine {
            amount += transaction.amount
        }

        return TransactionRecord(
                transactionHash: transaction.hash,
                transactionIndex: 0,
                interTransactionIndex: 0,
                blockHeight: transaction.blockHeight,
                amount: amount,
                fee: BinanceAdapter.transferFee,
                date: transaction.date,
                from: [from],
                to: [to]
        )
    }

}

extension BinanceAdapter {
    //todo: Make binanceKit errors public!
    enum AddressConversion: Error {
        case invalidAddress
    }

    static func clear(except excludedWalletIds: [String]) throws {
        try BinanceChainKit.clear(exceptFor: excludedWalletIds)
    }

}

extension BinanceAdapter: IAdapter {

    func start() {
        // started via BinanceKitManager
    }

    func stop() {
        // stopped via BinanceKitManager
    }

    func refresh() {
        // refreshed via BinanceKitManager
    }

    var debugInfo: String {
        return ""
    }

}

extension BinanceAdapter: IBalanceAdapter {

    var state: AdapterState {
        switch binanceKit.syncState {
        case .synced: return .synced
        case .notSynced: return .notSynced
        case .syncing: return .syncing(progress: 50, lastBlockDate: nil)
        }
    }

    var stateUpdatedObservable: Observable<Void> {
        return binanceKit.syncStateObservable.map { _ in () }
    }

    var balance: Decimal {
        return asset.balance
    }

    var balanceUpdatedObservable: Observable<Void> {
        return asset.balanceObservable.map { _ in () }
    }

}

extension BinanceAdapter: ISendBinanceAdapter {

    var availableBalance: Decimal {
        var balance = asset.balance
        if asset.symbol == "BNB" {
            balance -= BinanceAdapter.transferFee
        }
        return max(0, balance)
    }

    var availableBinanceBalance: Decimal {
        return binanceKit.binanceBalance
    }

    func validate(address: String) throws {
        //todo: remove when make errors public
        do {
            try binanceKit.validate(address: address)
        } catch {
            throw AddressConversion.invalidAddress
        }
    }

    var fee: Decimal {
        return BinanceAdapter.transferFee
    }

    func sendSingle(amount: Decimal, address: String, memo: String?) -> Single<Void> {
        return binanceKit.sendSingle(symbol: asset.symbol, to: address, amount: amount, memo: memo ?? "")
                .map { _ in () }
    }

}

extension BinanceAdapter: ITransactionsAdapter {
    var confirmationsThreshold: Int {
        return 1
    }

    var lastBlockHeight: Int? {
        return binanceKit.lastBlockHeight
    }

    var lastBlockHeightUpdatedObservable: Observable<Void> {
        return binanceKit.lastBlockHeightObservable.map { _ in () }
    }

    var transactionRecordsObservable: Observable<[TransactionRecord]> {
        return asset.transactionsObservable.map { [weak self] in
            $0.compactMap {
                self?.transactionRecord(fromTransaction: $0)
            }
        }
    }

    func transactionsSingle(from: (hash: String, interTransactionIndex: Int)?, limit: Int) -> Single<[TransactionRecord]> {
        return binanceKit.transactionsSingle(symbol: asset.symbol, fromTransactionHash: from?.hash, limit: limit)
                .map { [weak self] transactions -> [TransactionRecord] in
                    return transactions.compactMap { self?.transactionRecord(fromTransaction: $0) }
                }
    }

}

extension BinanceAdapter: IDepositAdapter {

    var receiveAddress: String {
        return binanceKit.account
    }

}
