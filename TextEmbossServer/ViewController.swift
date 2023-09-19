import UIKit
import Swifter
import TextEmboss
import Logging

public enum Errors: Error {
    case notFound
    case invalidImage
    case cgImage
    case processError
    case unsupportedOS
    case fileManager
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let server = HttpServer();
        let logger = Logger(label: "org.sfomuseum.text-emboss-server")

        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Failed to derive documents directory")
            fatalError("Errors.fileManager")
        }
        
        let port = 8080
        let max_size: Int = 10000000 // bytes
        
        server.post["/"] = { r in
            
            guard let myFileMultipart = r.parseMultiPartFormData().filter({ $0.name == "image" }).first else {
                logger.error("Request missing image parameter")
                return .badRequest(.text("Request missing image parameter"))
            }
            
            if myFileMultipart.body.count > max_size {
                logger.error("Request too large")
                return .badRequest(.text("Request too large"))
            }
            
            var ext = ""
            
            guard let content_type = myFileMultipart.headers["content-type"] else {
                logger.error("Missing content type")
                return .badRequest(.text("Missing content type"))
            }
            
            switch (content_type){
            case "image/jpeg":
                ext = ".jpg"
            case "image/png":
                ext = ".png"
            case "image/gif":
                ext = ".gif"
            case "image/tiff":
                ext = ".tiff"
            default:
                logger.error("Unsupported content type \(String(describing: content_type))")
                return .badRequest(.text("Invalid format"))
            }
            
            let uuid = UUID().uuidString
            let fname = uuid + ext
            
            let data: NSData = myFileMultipart.body.withUnsafeBufferPointer { pointer in
                return NSData(bytes: pointer.baseAddress, length: myFileMultipart.body.count)
            }
            
            guard let fileSaveUrl = NSURL(string: fname, relativeTo: documentsUrl) else {
                logger.error("Failed to derive file save URL")
                return .internalServerError(.text("Internal Server Error: URL"))
            }
            
            guard data.write(to: fileSaveUrl as URL, atomically: true) else {
                logger.error("Failed to write image data")
                return .internalServerError(.text("Internal Server Error: File"))
            }
            
            defer {
                do {
                    try FileManager.default.removeItem(at: fileSaveUrl as URL)
                } catch {
                    logger.error("Failed to remove \(fileSaveUrl.path!), \(error)")
                }
            }
            
            guard let im = UIImage(contentsOfFile:fileSaveUrl.path!) else {
                logger.error("Invalid image")
                return .badRequest(.text("Invalid image"))
            }
            
            guard let cgImage = im.cgImage else {
                logger.error("Failed to derive CG image")
                return .internalServerError(.text("Internal Server Error: CG"))
            }
            
            let emb = TextEmboss()
            let rsp = emb.ProcessImage(image: cgImage)
            
            switch rsp {
            case .failure(let error):
                logger.error("Failed to process image, \(error)")
                return .internalServerError(.text("Internal Server Error: Process"))
            case .success(let txt):
                return .ok(.text(txt))
            }
            
        }

        let semaphore = DispatchSemaphore(value: 0)
        
        do {
            try server.start(UInt16(port))
            let _port = try server.port()
            logger.info("Server has started on port \(_port) and is listening for requests.")
            semaphore.wait()
        } catch {
            semaphore.signal()
            logger.error("Failed to start server, \(error)")
            fatalError("Failed to start server")
        }
        
    }


}

