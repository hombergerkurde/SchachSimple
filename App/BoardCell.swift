import UIKit

final class BoardCell: UICollectionViewCell {
    static let reuseID = "BoardCell"

    let pieceLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(pieceLabel)
        NSLayoutConstraint.activate([
            pieceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pieceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pieceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            pieceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.layer.borderWidth = 0
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSquareColor(isLight: Bool) {
        contentView.backgroundColor = isLight ? UIColor.systemGray6 : UIColor.systemGray3
    }

    func setSelected(_ selected: Bool) {
        contentView.layer.borderWidth = selected ? 3 : 0
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : nil
    }
}
