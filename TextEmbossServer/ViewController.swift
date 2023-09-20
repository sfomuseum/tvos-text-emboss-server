import UIKit
import TextEmbossGRPC
import TextEmbossHTTP
import Logging

enum ServerMode: String {
    case http = "http"
    case grpc = "grpc"
}

class ViewController: UIViewController {

    let logger = Logger(label: "org.sfomuseum.text-emboss-server")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = UserDefaults.standard
        settings.synchronize()
        
        var host = settings.string(forKey: "Host")
        var port = settings.integer(forKey: "Port")
        var server_mode = settings.string(forKey: "ServerMode")
        
        if host == nil {
            host = "localhost"
        }
        
        if port <= 0 {
            port = 8080
        }
        
        if server_mode == nil {
            server_mode = "grpc"
        }
        
        switch ServerMode(rawValue: server_mode!) {
        case .grpc:
                                
            var threads = settings.integer(forKey: "Threads")
            
            if threads <= 0 {
                threads = 1
            }
            let s = TextEmbossGRPC.GRPCServer(logger: self.logger, threads: threads)
            
            func Run() throws {
                Task {
                    try await s.Run(host: host!, port: port)
                }
            }
            
            do {
                try Run()
            } catch {
                fatalError("Failed to start gRPC server")
            }
            
        case .http:
            
            var max_size = settings.integer(forKey: "MaxSize")

            if max_size <= 0 {
                max_size = 10000000
            }
            
            let s = TextEmbossHTTP.HTTPServer(logger: self.logger, max_size: max_size)
            
            do {
                try s.Run(host: host!, port: port)
            } catch {
                fatalError("Failed to start HTTP server")
            }
            
        default:
            fatalError("Invalid server mode")
        }
        
    }


}

