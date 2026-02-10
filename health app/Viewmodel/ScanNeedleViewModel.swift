import UIKit
import Combine

final class ScanNeedleViewModel: ObservableObject {

    @Published var scannedUnits: Int?
    @Published var isProcessing = false

    func process(image: UIImage, completion: @escaping (Int?) -> Void) {
        isProcessing = true

        VisionService.recognizeText(from: image) { [weak self] value in
            DispatchQueue.main.async {
                self?.isProcessing = false

                if let units = Int(value) {
                    self?.scannedUnits = units
                    completion(units)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

