public import SwiftUI

/// Greedy line-breaking layout for chip, tag, pill, and inline token groups.
///
/// Keep this primitive product-neutral: callers own text, colors, haptics, and
/// selection behavior; substrate owns only deterministic wrapping geometry.
public struct FlowLayout: Layout {
    public var spacing: CGFloat
    public var maxWidth: CGFloat?

    public init(spacing: CGFloat = 8, maxWidth: CGFloat? = nil) {
        self.spacing = spacing
        self.maxWidth = maxWidth
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        arrangeSubviews(proposal: proposal, subviews: subviews).size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let resolvedMaxWidth = proposal.width ?? maxWidth ?? bounds.width
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        let childProposal = ProposedViewSize(width: resolvedMaxWidth, height: nil)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: childProposal,
            )
        }
    }

    private func arrangeSubviews(
        proposal: ProposedViewSize,
        subviews: Subviews,
    ) -> (positions: [CGPoint], size: CGSize) {
        let resolvedMaxWidth = proposal.width ?? maxWidth ?? .infinity
        var positions = [CGPoint]()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        let childProposal = ProposedViewSize(width: resolvedMaxWidth, height: nil)
        for subview in subviews {
            let size = subview.sizeThatFits(childProposal)
            if currentX + size.width > resolvedMaxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxRowWidth = max(maxRowWidth, currentX - spacing)
        }

        return (positions, CGSize(width: maxRowWidth, height: currentY + rowHeight))
    }
}
