import UIKit
import SwiftChess

final class MenuViewController: UIViewController {

    private let colorControl: UISegmentedControl = {
        let c = UISegmentedControl(items: ["Weiß", "Schwarz"])
        c.selectedSegmentIndex = 0
        return c
    }()

    private let difficultyControl: UISegmentedControl = {
        let c = UISegmentedControl(items: AppDifficulty.allCases.map { $0.title })
        c.selectedSegmentIndex = 0
        return c
    }()

    private let pointsLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schach"
        view.backgroundColor = .systemBackground

        pointsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        pointsLabel.textAlignment = .center

        startButton.setTitle("Spiel starten", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        resetButton.setTitle("Punkte zurücksetzen", for: .normal)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            makeSection(title: "Farbe", control: colorControl),
            makeSection(title: "Schwierigkeit", control: difficultyControl),
            pointsLabel,
            startButton,
            resetButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        refreshPoints()
    }

    private func makeSection(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func refreshPoints() {
        pointsLabel.text = "Punkte: \(ScoreStore.shared.totalPoints)"
    }

    @objc private func startTapped() {
        let humanColor: Color = (colorControl.selectedSegmentIndex == 0) ? .white : .black
        let diff = AppDifficulty(rawValue: difficultyControl.selectedSegmentIndex) ?? .easy
        let config = GameConfig(humanColor: humanColor, difficulty: diff)

        let vc = ChessViewController(config: config)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func resetTapped() {
        ScoreStore.shared.reset()
        refreshPoints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPoints()
    }
}
