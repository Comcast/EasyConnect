/**
 *  @file  QRCodegenerator.swift
 *  @brief QRCode Generator implementation.
 */

import UIKit

class QRCodegenerator: NSObject {
    
    // MARK: - Generate QRCode Image
    ///  generate image
    ///
    ///  - parameter stringValue: string value to encode
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarScale: the scale for avatar image, default is 0.25
    ///
    ///  - returns: the generated image
    func generateQRCodeImage(_ stringValue: String, avatarImage: UIImage?, avatarScale: CGFloat = 0.25) -> UIImage? {
        return generateQRCodeImage(stringValue,
                                   avatarImage: avatarImage,
                                   avatarScale: avatarScale,
                                   color: CIColor(color: UIColor.red),
                                   backColor: CIColor(color: UIColor.green))
    }
    
    ///  Generate Qrcode Image
    ///
    ///  - parameter stringValue: string value to encode
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarScale: the scale for avatar image, default is 0.25
    ///  - parameter color:       the CI color for forenground, default is black
    ///  - parameter backColor:   th CI color for background, default is white
    ///
    ///  - returns: the generated image
    func generateQRCodeImage(_ stringValue: String,
                             avatarImage: UIImage?,
                             avatarScale: CGFloat = 0.25,
                             color: CIColor, backColor: CIColor) -> UIImage? {
        
        let data = stringValue.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("M", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                // scale qrcode image
                let colorFilter = CIFilter(name: "CIFalseColor")!
                colorFilter.setDefaults()
                colorFilter.setValue(color, forKey: "inputColor0")
                colorFilter.setValue(backColor, forKey: "inputColor1")
                colorFilter.setValue(output, forKey: "inputImage")
                
                let image = UIImage(ciImage: output)
                
                if avatarImage != nil {
                    
                    return insertAvatarImage(image, avatarImage: avatarImage!, scale: avatarScale)
                }
                return image
            }
        }
        return nil
    }

    ///  Insert Avatar Image
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarScale: the scale for avatar image, default is 0.25
    ///
    ///  - returns: the generated image
    func insertAvatarImage(_ codeImage: UIImage, avatarImage: UIImage, scale: CGFloat) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        codeImage.draw(in: rect)
        
        let avatarSize = CGSize(width: rect.size.width * scale, height: rect.size.height * scale)
        let xAxis = (rect.width - avatarSize.width) * 0.5
        let yAxis = (rect.height - avatarSize.height) * 0.5
        avatarImage.draw(in: CGRect(x: xAxis, y: yAxis, width: avatarSize.width, height: avatarSize.height))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
}
