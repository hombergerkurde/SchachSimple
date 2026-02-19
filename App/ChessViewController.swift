import UIKit
import SwiftChess

final class ChessViewController: UIViewController {

    private let config: GameConfig

    private let drawTracker = FideDrawTracker()

    private var game: Game!
    private var humanPlayer: Human!
    private var aiPlayer: AIPlayer!

    private var selected: BoardLocation?

    private var lastMoveWasPawnMove = false
    private var lastMoveWasCapture = false
    private var isGameOver = false

    private lazy var statusLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private lazy var pointsLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    private lazy var boardView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = .clear
        v.register(BoardCell.self, forCellWithReuseIdentifier: BoardCell.reuseID)
        v.dataSource = self
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isScrollEnabled = false
        return v
    }()

    init(config: GameConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spiel"
        view.backgroundColor = .systemBackground

        pointsLabel.text = "Punkte: \(ScoreStore.shared.totalPoints)"

        let stack = UIStackView(arrangedSubviews: [pointsLabel, boardView, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        let side = min(view.bounds.width - 24, view.bounds.height - 220)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            boardView.heightAnchor.constraint(equalToConstant: max(280, side))
        ])

        startNewGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = boardView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let size = floor(boardView.bounds.width / 8)
        layout.itemSize = CGSize(width: size, height: size)
    }

    private func startNewGame() {
        isGameOver = false
        selected = nil

        let white: Player
        let black: Player

        if config.humanColor == .white {
            humanPlayer = Human(color: .white)
            aiPlayer = AIPlayer(color: .black, configuration: AIConfiguration(difficulty: config.difficulty.aiDifficulty))
            white = humanPlayer
            black = aiPlayer
        } else {
            humanPlayer = Human(color: .black)
            aiPlayer = AIPlayer(color: .white, configuration: AIConfiguration(difficulty: config.difficulty.aiDifficulty))
            white = aiPlayer
            black = humanPlayer
        }

        game = Game(firstPlayer: white, secondPlayer: black)
        game.delegate = self

        drawTracker.reset(game: game)

        updateStatus()
        boardView.reloadData()

        maybeMakeAIMove()
    }

    private func updateStatus(_ extra: String? = nil) {
        if isGameOver {
            statusLabel.text = extra ?? "Spiel beendet"
            return
        }

        let turnColor = game.currentPlayer.color
        let youToMove = (turnColor == config.humanColor)
        let who = youToMove ? "Du bist am Zug" : "Computer denkt…"
        let color = (config.humanColor == .white) ? "Du spielst Weiß" : "Du spielst Schwarz"

        if let extra {
            statusLabel.text = "\(color) · \(who)\n\(extra)"
        } else {
            statusLabel.text = "\(color) · \(who)"
        }

        pointsLabel.text = "Punkte: \(ScoreStore.shared.totalPoints)"
    }

    private func maybeMakeAIMove() {
        guard !isGameOver else { return }
        guard game.currentPlayer.color != config.humanColor else { return }

        boardView.isUserInteractionEnabled = false
        updateStatus()

        // Asynchronous AI move
        aiPlayer.makeMoveAsync()
    }

    private func endGame(title: String, message: String, addWinPoints: Bool) {
        guard !isGameOver else { return }
        isGameOver = true
        boardView.isUserInteractionEnabled = false

        var finalMessage = message
        if addWinPoints {
            let newTotal = ScoreStore.shared.addWin(points: config.difficulty.winPoints)
            finalMessage += "\n\n+\(config.difficulty.winPoints) Punkte (Total: \(newTotal))"
        }

        let alert = UIAlertController(title: title, message: finalMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func handleClaimableDraw(reason: String) {
        guard !isGameOver else { return }

        // Only the player having the move may claim. We call this when current player changed.
        if game.currentPlayer.color == config.humanColor {
            let alert = UIAlertController(title: "Remis möglich", message: reason, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Weiterspielen", style: .cancel) { [weak self] _ in
                self?.updateStatus()
                self?.boardView.isUserInteractionEnabled = true
            })
            alert.addAction(UIAlertAction(title: "Remis reklamieren", style: .default) { [weak self] _ in
                self?.endGame(title: "Unentschieden", message: reason, addWinPoints: false)
            })
            present(alert, animated: true)
        } else {
            // AI claims automatically.
            endGame(title: "Unentschieden", message: reason, addWinPoints: false)
        }
    }

    private func pieceSymbol(_ p: Piece) -> String {
        switch (p.type, p.color) {
        case (.king, .white): return "♔"
        case (.queen, .white): return "♕"
        case (.rook, .white): return "♖"
        case (.bishop, .white): return "♗"
        case (.knight, .white): return "♘"
        case (.pawn, .white): return "♙"
        case (.king, .black): return "♚"
        case (.queen, .black): return "♛"
        case (.rook, .black): return "♜"
        case (.bishop, .black): return "♝"
        case (.knight, .black): return "♞"
        case (.pawn, .black): return "♟︎"
        }
    }

    private func locationForIndex(_ indexPath: IndexPath) -> BoardLocation {
        let dispRow = indexPath.item / 8
        let dispCol = indexPath.item % 8

        if config.humanColor == .white {
            // White at bottom
            let x = dispCol
            let y = 7 - dispRow
            return BoardLocation(x: x, y: y)
        } else {
            // Black at bottom (rotate 180)
            let x = 7 - dispCol
            let y = dispRow
            return BoardLocation(x: x, y: y)
        }
    }

    private func displayCoords(for boardLoc: BoardLocation) -> (row: Int, col: Int) {
        if config.humanColor == .white {
            // inverse of above: y = 7 - row, x = col
            return (row: 7 - boardLoc.y, col: boardLoc.x)
        } else {
            // inverse: y=row, x=7-col
            return (row: boardLoc.y, col: 7 - boardLoc.x)
        }
    }
}

// MARK: - UICollectionView

extension ChessViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        64
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCell.reuseID, for: indexPath) as? BoardCell else {
            return UICollectionViewCell()
        }

        let boardLoc = locationForIndex(indexPath)
        let isLight = (boardLoc.x + boardLoc.y) % 2 == 0
        cell.setSquareColor(isLight: isLight)

        if let p = game.board.getPiece(at: boardLoc) {
            cell.pieceLabel.text = pieceSymbol(p)
        } else {
            cell.pieceLabel.text = ""
        }

        cell.setSelected(selected == boardLoc)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isGameOver else { return }
        guard game.currentPlayer.color == config.humanColor else { return }

        let tapped = locationForIndex(indexPath)

        if let selected {
            if selected == tapped {
                self.selected = nil
                boardView.reloadData()
                return
            }

            // try move
            do {
                try humanPlayer.movePiece(from: selected, to: tapped)
                self.selected = nil
                boardView.reloadData()
                boardView.isUserInteractionEnabled = false
            } catch {
                // invalid move
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

        } else {
            if let p = game.board.getPiece(at: tapped), p.color == config.humanColor {
                self.selected = tapped
                boardView.reloadData()
            }
        }
    }
}

// MARK: - GameDelegate

extension ChessViewController: GameDelegate {

    func gameDidMovePiece(game: Game, piece: Piece, toLocation: BoardLocation) {
        if piece.type == .pawn { lastMoveWasPawnMove = true }
        boardView.reloadData()
    }

    func gameDidRemovePiece(game: Game, piece: Piece, location: BoardLocation) {
        lastMoveWasCapture = true
        boardView.reloadData()
    }

    func gameDidTransformPiece(game: Game, piece: Piece, location: BoardLocation) {
        // Pawn was promoted (SwiftChess does this internally)
        boardView.reloadData()
    }

    func gameWonByPlayer(game: Game, player: Player) {
        let humanWon = (player.color == config.humanColor)
        endGame(title: "Schachmatt", message: humanWon ? "Du hast gewonnen." : "Der Computer hat gewonnen.", addWinPoints: humanWon)
    }

    func gameEndedInStaleMate(game: Game) {
        endGame(title: "Unentschieden", message: "Patt – Unentschieden.", addWinPoints: false)
    }

    func gameDidChangeCurrentPlayer(game: Game) {
        guard !isGameOver else { return }

        // Evaluate (claimable/automatic) draw rules.
        if let event = drawTracker.updateAfterMove(game: game,
                                                   lastMoveWasPawnMove: lastMoveWasPawnMove,
                                                   lastMoveWasCapture: lastMoveWasCapture) {
            // Reset flags for next move evaluation
            lastMoveWasPawnMove = false
            lastMoveWasCapture = false

            switch event {
            case .automatic(let reason):
                endGame(title: "Unentschieden", message: reason, addWinPoints: false)
                return
            case .claimable(let reason):
                // Stop interaction while the dialog is open
                boardView.isUserInteractionEnabled = false
                handleClaimableDraw(reason: reason)
                return
            }
        }

        // Reset flags for next move evaluation
        lastMoveWasPawnMove = false
        lastMoveWasCapture = false

        // Allow interaction if it's the human's turn.
        if game.currentPlayer.color == config.humanColor {
            boardView.isUserInteractionEnabled = true
        }

        updateStatus()
        maybeMakeAIMove()
    }
}
