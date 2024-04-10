//
//  IntelligenceCategoryView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import SwiftUI

struct IntelligenceCategoryView: View {
    @ObservedObject var presenter: MainPresenter
    private let selectedBGColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)
    private let nonSelectedBGColor = Color.clear
    private let dividerHeight: CGFloat = 10

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(presenter.intelligentArray, id: \.self) { intelligent in
                    HStack {
                        Text(intelligent.name)
                            .fontWeight(.medium)
                            .padding(8)
                            .background(self.getBindingInstance(intelligent).wrappedValue.isSelected ? self.selectedBGColor : self.nonSelectedBGColor)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        
                        Divider().frame(height: self.dividerHeight)
                    }
                    .padding()
                    .onTapGesture {
                        self.getBindingInstance(intelligent).wrappedValue.isSelected = true
                        self.presenter.update(intelligent: intelligent)
                    }
                }
            }
        }
    }

    func getBindingInstance(_ intelligent: Intelligent) -> Binding<Intelligent> {
        $presenter.intelligentArray[presenter.intelligentArray.firstIndex(of: intelligent)!]
    }
}

struct IntelligenceCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        IntelligenceCategoryView(presenter: MainPresenter())
    }
}
