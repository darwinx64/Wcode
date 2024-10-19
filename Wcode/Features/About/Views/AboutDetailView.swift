//
//  AboutDetailView.swift
//  Wcode
//
//  Created by paige on 10/19/24.
//

/// src: https://github.com/CodeEditApp/CodeEdit/blob/main/CodeEdit/Features/About/Views/AboutView.swift

import SwiftUI

struct AboutDetailView<Content: View>: View {
    var title: String

    @Binding var aboutMode: AboutMode

    var namespace: Namespace.ID

    @ViewBuilder var content: Content

    let smallTitlebarHeight: CGFloat = 28
    let mediumTitlebarHeight: CGFloat = 113
    let largeTitlebarHeight: CGFloat = 231

    var maxScrollOffset: CGFloat {
        smallTitlebarHeight - mediumTitlebarHeight
    }

    var currentOffset: CGFloat {
        getScrollAdjustedValue(
            minValue: 22,
            maxValue: 14,
            minOffset: 0,
            maxOffset: maxScrollOffset
        )
    }

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        VStack {
            Spacer(minLength: smallTitlebarHeight + 1)
            TrackableScrollView(showIndicators: false, contentOffset: $scrollOffset) {
                Spacer(minLength: mediumTitlebarHeight - smallTitlebarHeight - 1 + 8)
                content
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .matchedGeometryEffect(id: "ScrollView", in: namespace, properties: .position, anchor: .top)
            .clipShape(Rectangle())
            Image(systemName: "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.pink.opacity(0.5))
                .padding(.bottom, 10)
                .frame(width: 24, height: 24)
        }

        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .matchedGeometryEffect(id: "AppIcon", in: namespace)
                .frame(
                    width: getScrollAdjustedValue(
                        minValue: 48,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    ),
                    height: getScrollAdjustedValue(
                        minValue: 48,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    )
                )
                .opacity(
                    getScrollAdjustedValue(
                        minValue: 1,
                        maxValue: 0,
                        minOffset: 0,
                        maxOffset: maxScrollOffset
                    )
                )
                .padding(.top, getScrollAdjustedValue(
                    minValue: smallTitlebarHeight,
                    maxValue: 0,
                    minOffset: 0,
                    maxOffset: maxScrollOffset
                ))
                .padding(.bottom, getScrollAdjustedValue(
                    minValue: 5,
                    maxValue: 0,
                    minOffset: 0,
                    maxOffset: maxScrollOffset
                ))

            Button {
                aboutMode = .about
            } label: {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.system(
                            size: getScrollAdjustedValue(
                                minValue: 20,
                                maxValue: 14,
                                minOffset: 0,
                                maxOffset: maxScrollOffset
                            ),
                            weight: .bold
                        ))

                    .fixedSize(horizontal: true, vertical: false)
                    .frame(minHeight: smallTitlebarHeight)
                    .padding(.horizontal, 13)
                    .overlay(alignment: .leading) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                    }
                    .contentShape(Rectangle())
                    .matchedGeometryEffect(id: "Title", in: namespace, properties: .position, anchor: .center)
            }
            .buttonStyle(.plain)

            Divider()
                .opacity(getScrollAdjustedValue(
                    minValue: 0,
                    maxValue: 1,
                    minOffset: 0,
                    maxOffset: maxScrollOffset
                ))
        }
        .padding(0)
        .frame(maxWidth: .infinity)
        .matchedGeometryEffect(id: "Titlebar", in: namespace, properties: .position, anchor: .bottom)
    }

    func getScrollAdjustedValue(
        minValue: CGFloat,
        maxValue: CGFloat,
        minOffset: CGFloat,
        maxOffset: CGFloat
    ) -> CGFloat {
        let valueRange = maxValue - minValue
        let offsetRange = maxOffset - minOffset
        let currentOffset = scrollOffset
        let percentage = (currentOffset - minOffset) / offsetRange
        let value = minValue + (valueRange * percentage)

        if currentOffset <= maxOffset {
            return maxValue
        }
        if value < 0 {
            return 0
        }
        return value
    }
}
