import UIKit
import TextEmbossGRPC
import TextEmbossHTTP
import Logging

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logger = Logger(label: "org.sfomuseum.text-emboss-server")
        let host = "localhost"
        let port = 1234
        
        var grpc = true
        
        if grpc {
                                
            let threads = 1
            
            let s = TextEmbossGRPC.GRPCServer(logger: logger, threads: threads)
            
            func Run() throws {
                Task {
                    try await s.Run(host: host, port: port)
                }
            }
            
            do {
                try Run()
            } catch {
                fatalError("SAD")
            }
            
        } else {
            
            let max_size = 10000000
            
            let s = TextEmbossHTTP.HTTPServer(logger: logger, max_size: max_size)
            
            do {
                try s.Run(host: host, port: port)
            } catch {
                fatalError("SAD")
            }
        }
        
    }


}

