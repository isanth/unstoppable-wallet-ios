import UIKit
import SnapKit

class RestoreOptionCell: AppCell {
    private let leftView = DoubleLineCellView()
    private let rightView = CheckmarkCellView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(leftView)
        leftView.snp.makeConstraints { maker in
            maker.leading.top.bottom.equalToSuperview()
        }

        contentView.addSubview(rightView)
        rightView.snp.makeConstraints { maker in
            maker.trailing.top.bottom.equalToSuperview()
            maker.leading.equalTo(leftView.snp.trailing)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(title: String, subtitle: String, selected: Bool, last: Bool = false) {
        super.bind(last: last)

        leftView.bind(title: title, subtitle: subtitle)
        rightView.bind(visible: selected)
    }

}
