import UIKit
import Vision

enum VisionService {

    static func recognizeText(from image: UIImage,
                              completion: @escaping (String) -> Void) {

        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            let text = (request.results as? [VNRecognizedTextObservation])?
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ") ?? ""

            // نطلع الأرقام فقط
            let numbers = text.filter { $0.isNumber }
            completion(numbers)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

