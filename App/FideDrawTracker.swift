import Foundation
import SwiftChess

/// FIDE Laws of Chess (01/01/2023):
/// - Claimable: threefold repetition (9.2), 50-move rule (9.3)
/// - Automatic: fivefold repetition (9.6.1), 75-move rule (9.6.2)
/// - Immediate draw: stalemate (5.2.1) and dead position (5.2.2)
final class FideDrawTracker {

    enum Event {
        case automatic(reason: String)
        case claimable(reason: String)
    }

    // 50-move rule: 50 moves by each player = 100 halfmoves/plies
    private static let claimableHalfmoves = 100

    // 75-move rule: 75 moves by each player = 150 halfmoves/plies
    private static let automaticHalfmoves = 150

    private var halfmoveClock: Int = 0
    private var seen: [PositionKey: Int] = [:]

    func reset(game: Game) {
        halfmoveClock = 0
        seen.removeAll()
        registerCurrentPosition(game: game)
    }

    /// Call after a move is completed and the current player has changed.
    /// Returns a draw event (automatic or claimable) if applicable.
    func updateAfterMove(game: Game,
                         lastMoveWasPawnMove: Bool,
                         lastMoveWasCapture: Bool) -> Event? {

        // Dead position (conservative set of cases)
        if let reason = deadPositionReason(board: game.board) {
            return .automatic(reason: reason)
        }

        if lastMoveWasPawnMove || lastMoveWasCapture {
            halfmoveClock = 0
        } else {
            halfmoveClock += 1
        }

        // Register & count repetition of current position
        let key = PositionKey(game: game)
        let count = (seen[key] ?? 0) + 1
        seen[key] = count

        // Automatic draws
        if count >= 5 {
            return .automatic(reason: "Fünffache Stellungswiederholung (FIDE 9.6.1).")
        }

        if halfmoveClock >= Self.automaticHalfmoves {
            return .automatic(reason: "75‑Züge‑Regel (FIDE 9.6.2).")
        }

        // Claimable draws
        if count >= 3 {
            return .claimable(reason: "Dreifache Stellungswiederholung (FIDE 9.2) – Remis kann reklamiert werden.")
        }

        if halfmoveClock >= Self.claimableHalfmoves {
            return .claimable(reason: "50‑Züge‑Regel (FIDE 9.3) – Remis kann reklamiert werden.")
        }

        return nil
    }

    private func registerCurrentPosition(game: Game) {
        let key = PositionKey(game: game)
        seen[key] = (seen[key] ?? 0) + 1
    }

    // MARK: - Dead position (5.2.2)

    /// Conservative dead-position detection: we only declare a draw in cases that are guaranteed
    /// to be a dead position (no possible mate for either side).
    private func deadPositionReason(board: Board) -> String? {
        // If any pawn/rook/queen exists => mate is generally possible; do NOT call it dead.
        var hasPawnOrMajor = false

        var wB = 0, wN = 0
        var bB = 0, bN = 0

        for y in 0..<8 {
            for x in 0..<8 {
                let loc = BoardLocation(x: x, y: y)
                guard let p = board.getPiece(at: loc) else { continue }
                switch p.type {
                case .pawn, .rook, .queen:
                    hasPawnOrMajor = true
                case .bishop:
                    if p.color == .white { wB += 1 } else { bB += 1 }
                case .knight:
                    if p.color == .white { wN += 1 } else { bN += 1 }
                case .king:
                    break
                }
            }
        }

        if hasPawnOrMajor {
            return nil
        }

        // If either side has bishop+knight or 2 bishops => mate possible.
        if (wB >= 1 && wN >= 1) || (bB >= 1 && bN >= 1) {
            return nil
        }
        if wB >= 2 || bB >= 2 {
            return nil
        }

        let totalMinors = (wB + wN + bB + bN)

        // Guaranteed dead positions we accept:
        // - K vs K
        // - K+minor vs K
        // - K+minor vs K+minor (any combination of single minors)
        // - K+NN vs K
        if totalMinors == 0 {
            return "Dead Position (nur Könige) – Remis (FIDE 5.2.2)."
        }

        // K + single minor vs K
        if totalMinors == 1 {
            return "Dead Position (König + leichte Figur) – Remis (FIDE 5.2.2)."
        }

        // Exactly two minors total:
        // - one each side (e.g. B vs N, N vs N, B vs B)
        // - or both on one side: allow only NN (two knights) as dead; other 2-minor combos can mate? (BB can mate; BN can mate)
        if totalMinors == 2 {
            let whiteMinors = wB + wN
            let blackMinors = bB + bN

            if whiteMinors == 1 && blackMinors == 1 {
                return "Dead Position (nur leichte Figuren) – Remis (FIDE 5.2.2)."
            }

            // Both minors on one side
            if (whiteMinors == 2 && blackMinors == 0) || (blackMinors == 2 && whiteMinors == 0) {
                // Only NN is guaranteed dead; BB or BN can mate.
                if (wN == 2 && wB == 0) || (bN == 2 && bB == 0) {
                    return "Dead Position (König + zwei Springer gegen König) – Remis (FIDE 5.2.2)."
                }
            }
        }

        return nil
    }
}

/// Position identity for repetition.
/// We approximate FIDE 9.2.2 by including:
/// - side to move
/// - piece placement
/// - castling rights (derived from unmoved king/rook on start squares)
/// - en-passant availability (file of pawn that can be captured en-passant)
struct PositionKey: Hashable {
    let sideToMove: Color
    let castlingMask: UInt8 // 1=K,2=Q,4=k,8=q
    let enPassantFile: Int8 // -1 none
    let pieceBytes: [UInt8] // 64

    init(game: Game) {
        self.sideToMove = game.currentPlayer.color
        self.castlingMask = PositionKey.computeCastlingMask(board: game.board)
        self.enPassantFile = PositionKey.computeEnPassantFile(board: game.board)
        self.pieceBytes = PositionKey.computePieceBytes(board: game.board)
    }

    private static func computePieceBytes(board: Board) -> [UInt8] {
        var arr = [UInt8](repeating: 0, count: 64)
        for y in 0..<8 {
            for x in 0..<8 {
                let loc = BoardLocation(x: x, y: y)
                guard let p = board.getPiece(at: loc) else { continue }

                let base: UInt8
                switch p.type {
                case .pawn:   base = 1
                case .knight: base = 2
                case .bishop: base = 3
                case .rook:   base = 4
                case .queen:  base = 5
                case .king:   base = 6
                }

                let colorBit: UInt8 = (p.color == .white) ? 0 : 8
                let idx = (y * 8) + x
                arr[idx] = base | colorBit
            }
        }
        return arr
    }

    private static func computeEnPassantFile(board: Board) -> Int8 {
        // SwiftChess exposes canBeTakenByEnPassant on a pawn.
        for y in 0..<8 {
            for x in 0..<8 {
                let loc = BoardLocation(x: x, y: y)
                guard let p = board.getPiece(at: loc) else { continue }
                if p.type == .pawn && p.canBeTakenByEnPassant {
                    return Int8(x)
                }
            }
        }
        return -1
    }

    private static func computeCastlingMask(board: Board) -> UInt8 {
        func pieceAt(_ type: Piece.PieceType, _ color: Color, x: Int, y: Int) -> Piece? {
            let loc = BoardLocation(x: x, y: y)
            guard let p = board.getPiece(at: loc), p.type == type, p.color == color else { return nil }
            return p
        }

        var m: UInt8 = 0

        // White: king e1 (4,0), rooks a1 (0,0), h1 (7,0)
        if let wk = pieceAt(.king, .white, x: 4, y: 0), wk.hasMoved == false {
            if let wrh = pieceAt(.rook, .white, x: 7, y: 0), wrh.hasMoved == false { m |= 1 }
            if let wra = pieceAt(.rook, .white, x: 0, y: 0), wra.hasMoved == false { m |= 2 }
        }

        // Black: king e8 (4,7), rooks a8 (0,7), h8 (7,7)
        if let bk = pieceAt(.king, .black, x: 4, y: 7), bk.hasMoved == false {
            if let brh = pieceAt(.rook, .black, x: 7, y: 7), brh.hasMoved == false { m |= 4 }
            if let bra = pieceAt(.rook, .black, x: 0, y: 7), bra.hasMoved == false { m |= 8 }
        }

        return m
    }
}
