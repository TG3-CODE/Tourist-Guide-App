//
//  Extensions.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit

extension UIImage {
    static func loadFromDocumentsDirectory(imageName: String) -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(imageName)
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    func saveToDocumentsDirectory(withName name: String) -> Bool {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return false }
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }

    static func placeholderImage(withText text: String, size: CGSize, backgroundColor: UIColor = .systemGray5, textColor: UIColor = .darkGray) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.width * 0.2),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attrs)
            let textRect = CGRect(
                x: 0,
                y: (size.height - attributedString.size().height) / 2,
                width: size.width,
                height: attributedString.size().height
            )
            
            attributedString.draw(in: textRect)
        }
    }
}
extension UIViewController {
    func showLoadingIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
extension Date {
    func formattedString(format: String = "MMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
