//
//  Presenter.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import Foundation
import UIKit

protocol Intelligence {
    var modelOptions: [ModelOption] { get set }
    func process(image: UIImage, with option: ModelOption, onCompletion: @escaping (IntelligenceOutput?) -> Void)
}

struct ModelOption: Hashable {
    var id = UUID()
    var modelFileName: String
    var modelOptionParameter: String?
    var isSelected = false
}

struct IntelligenceOutput {
    var image: UIImage?
    var confidence: Float
    var executionTime: Float
    var title: String
    var modelSize: Float
    var imageSize: CGSize
}

struct Intelligent: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Intelligent, rhs: Intelligent) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()
    var name: String
    var object: Intelligence
    var isSelected = false
}

class MainPresenter: ObservableObject {
    @Published var intelligentArray = [Intelligent]()
    @Published var output: IntelligenceOutput
    @Published var uiImage: UIImage
    @Published var loading = false

//    private let edgeDetector = EdgeDetector()
    private let depthMapper = DepthMapGenerator()
    @Published var selectedIntelligent: Intelligent
    private var selectedModel: ModelOption

    init() {
        output =
            IntelligenceOutput(
                image: nil,
                confidence: 0,
                executionTime: 0,
                title: "",
                modelSize: 0,
                imageSize: CGSize(width: 0, height: 0)
            )
        var intelligent1 = Intelligent(name: "Depth Mapping", object: depthMapper as! Intelligence)
        selectedIntelligent = intelligent1
        intelligent1.isSelected = true
        selectedModel = intelligent1.object.modelOptions.first!

        uiImage  = UIImage(named: "de") ?? MainPresenter.from(color: UIColor.gray)
        
        intelligentArray.append(intelligent1)
        
        selectModel(model: selectedModel)
    }

    func update(image: UIImage) {
        uiImage = image
        executeOperation()
    }

    func update(intelligent: Intelligent) {
        removePreviousSelection(excludeing: intelligent)
        selectedIntelligent = intelligent
        selectedModel = intelligent.object.modelOptions.first!
        removePreviousSelection(excludeing: selectedModel)
        selectModel(model: selectedModel)
        executeOperation()
    }

    func updateIntelligent(model: ModelOption) {
        selectedModel = model
        removePreviousSelection(excludeing: selectedModel)
        selectModel(model: selectedModel)
        executeOperation()
    }

    private func selectModel(model: ModelOption) {
        for index in 0 ..< intelligentArray.count {
            if let ind = intelligentArray[index].object.modelOptions.firstIndex(where: { model == $0 }) {
                intelligentArray[index].object.modelOptions[ind].isSelected = true
            }
        }
    }

    private func removePreviousSelection(excludeing it: ModelOption) {
        for index in 0 ..< intelligentArray.count {
            if let ind = intelligentArray[index].object.modelOptions.firstIndex(where: { $0.isSelected && it != $0 }) {
                intelligentArray[index].object.modelOptions[ind].isSelected = false
            }
        }
    }

    private func removePreviousSelection(excludeing it: Intelligent) {
        if let index = intelligentArray.firstIndex(where: { $0.isSelected && it != $0 }) {
            intelligentArray[index].isSelected = false
            if let ind = intelligentArray[index].object.modelOptions.firstIndex(where: { $0.isSelected }) {
                intelligentArray[index].object.modelOptions[ind].isSelected = false
            }
        }
    }

    private func executeOperation() {
        let startTime = CACurrentMediaTime()
        DispatchQueue.main.async {
            self.loading = true
        }
        DispatchQueue.global().async {
            self.selectedIntelligent.object.process(image: self.uiImage, with: self.selectedModel) { output in
                if output != nil {
                    let endTime = CACurrentMediaTime()
                    let interval = (endTime - startTime) * 1000

                    DispatchQueue.main.async {
                        self.output = output!
                        self.output.executionTime = Float(interval)
                        self.loading = false
                    }
                }
            }
        }
    }

    private static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
