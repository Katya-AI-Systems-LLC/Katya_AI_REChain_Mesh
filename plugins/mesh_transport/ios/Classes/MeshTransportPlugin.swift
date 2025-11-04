import Flutter
import UIKit
import MultipeerConnectivity

public class MeshTransportPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
  var eventSink: FlutterEventSink?
  let serviceType = "mesh-transport"
  var peerID: MCPeerID!
  var session: MCSession!
  var advertiser: MCNearbyServiceAdvertiser!
  var browser: MCNearbyServiceBrowser!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "katya.mesh/transport", binaryMessenger: registrar.messenger())
    let instance = MeshTransportPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let events = FlutterEventChannel(name: "katya.mesh/transport/events", binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "discover":
      self.ensureSession()
      self.browser.startBrowsingForPeers()
      result(true)
    case "stopDiscover": result(true)
    case "advertise":
      self.ensureSession()
      self.advertiser.startAdvertisingPeer()
      result(true)
    case "stopAdvertise": result(true)
    case "connect":
      // Multipeer invites happen via browser callback; nothing to do here
      result(true)
    case "send":
      if let args = call.arguments as? [String: Any], let data = args["data"] as? [Int] {
        self.ensureSession()
        let d = Data(data.map { UInt8($0) })
        try? self.session.send(d, toPeers: self.session.connectedPeers, with: .reliable)
        result(true)
      } else {
        result(FlutterError(code: "ARGS", message: "data required", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func ensureSession() {
    if peerID == nil {
      peerID = MCPeerID(displayName: UIDevice.current.name)
      session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
      session.delegate = self
      advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
      advertiser.delegate = self
      browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
      browser.delegate = self
    }
  }

  // MARK: Advertiser
  public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }
  public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}

  // MARK: Browser
  public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    eventSink?(["type": "peerFound", "id": peerID.displayName, "name": peerID.displayName, "rssi": -40])
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
  }
  public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
  public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}

  // MARK: Session
  public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
  public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    eventSink?(["type": "message", "fromId": peerID.displayName, "data": [UInt8](data)])
  }
  public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}


