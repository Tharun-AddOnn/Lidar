import Foundation
import RoomPlan
import ARKit
import UIKit

@available(iOS 16.0, *)
@objc(Lidar) 
class Lidar : CDVPlugin, RoomCaptureViewDelegate, RoomCaptureSessionDelegate,UIViewController {
    var _callbackId: String?
    var modelName: String
        var range: Double
    
    override init(){
        self.modelName = "BoardOnn"
        self.range = 0
        super.init()
    }
        
        // Initialize Lidar
        init(modelName: String, range: Double) {
            self.modelName = modelName
            self.range = range
        }
        
        // MARK: - NSCoding
        
        required convenience init?(coder aDecoder: NSCoder) {
            guard let modelName = aDecoder.decodeObject(forKey: "modelName") as? String,
                  let range = aDecoder.decodeDouble(forKey: "range") as? Double else {
                return nil
            }
            
            self.init(modelName: modelName, range: range)
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(modelName, forKey: "modelName")
            aCoder.encode(range, forKey: "range")
        }

    @IBOutlet var exportButton: UIButton? 
    @IBOutlet var doneButton: UIBarButtonItem?
    @IBOutlet var cancelButton: UIBarButtonItem?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?

    private var isScanning: Bool = false

    var roomCaptureView: RoomCaptureView?
    var roomCaptureSessionConfig = RoomCaptureSession.Configuration()
    var finalResults: CapturedRoom?

    @objc(isLiDARAvailable:)
    func isLiDARAvailable(command: CDVInvokedUrlCommand) {
        let available = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: available)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(startScanning:)
    func startScanning(command: CDVInvokedUrlCommand) {
        _callbackId = command.callbackId
        guard let view = self.webView else {
            return
        }
        DispatchQueue.main.async {
            self.roomCaptureView = RoomCaptureView(frame: view.bounds)
            self.roomCaptureView?.captureSession.delegate = self
            self.roomCaptureView?.delegate = self
            
            view.addSubview(self.roomCaptureView!)
            
            // Start the scanning session
            self.roomCaptureView?.captureSession.run(configuration: self.roomCaptureSessionConfig)
            
            // Return success callback to Cordova
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            //self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }


    @objc(stopScanning:)
    func stopScanning(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            // Stop the scanning session
            self.roomCaptureView?.captureSession.stop()
            self.roomCaptureView?.removeFromSuperview()
            self.roomCaptureView = nil
            
            // Return success callback to Cordova
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send( , callbackId: command.callbackId)
        }
    }
    
    // Delegate method for capturing room data
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    // Delegate method for presenting processed results
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        self.finalResults = processedResult
    }

    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    // Export the USDZ output by specifying the `.parametric` export option.
    // Alternatively, `.mesh` exports a nonparametric file and `.all`
    // exports both in a single USDZ.
    @IBAction func exportResults(_ sender: UIButton) {
        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
        let destinationURL = destinationFolderURL.appending(path: "Room.usdz")
        let capturedRoomURL = destinationFolderURL.appending(path: "Room.json")
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(finalResults)
            try jsonData.write(to: capturedRoomURL)
            try finalResults?.export(to: destinationURL, exportOptions: .parametric)
            
            let activityVC = UIActivityViewController(activityItems: [destinationFolderURL], applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            
            present(activityVC, animated: true, completion: nil)
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = self.exportButton
            }
        } catch {
            print("Error = \(error)")
        }
    }
}