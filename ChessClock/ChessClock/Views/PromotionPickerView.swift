import SwiftUI

/// Overlay that lets the user pick a promotion piece (Q, R, B, N).
/// The picker column is positioned at the promotion file, pinned to the top row.
struct PromotionPickerView: View {
    let color: PieceColor
    let promotionFile: Int
    let isFlipped: Bool
    let onPick: (PieceType) -> Void

    private let options: [PieceType] = [.queen, .rook, .bishop, .knight]

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Scrim
            Color.black.opacity(0.30)

            // Piece column at promotion file
            VStack(spacing: 1) {
                ForEach(options, id: \.self) { pieceType in
                    Button {
                        onPick(pieceType)
                    } label: {
                        Image(ChessPiece(type: pieceType, color: color).imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: ChessClockSize.square, height: ChessClockSize.square)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.badge))
                    }
                    .buttonStyle(.plain)
                }
            }
            .offset(x: CGFloat(promotionFile) * ChessClockSize.square)
        }
    }
}
