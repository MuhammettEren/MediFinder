import SwiftUI

/// Horizontal search section selector.
struct SearchTabBarView: View {
    let tabs: [SearchTab]
    let selectedTab: SearchTab
    let onSelect: (SearchTab) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tabs) { tab in
                    SelectableChipView(
                        title: tab.displayName,
                        isSelected: selectedTab == tab
                    ) {
                        onSelect(tab)
                    }
                }
            }
            .responsiveHorizontalPadding(percent: 0.043)
            .padding(.vertical, 14)
        }
        .background(Color.labelWhite)
    }
}
