import Flutter
import PushKit
import UIKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
  private var voipRegistry: PKPushRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureVoIPRegistry()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureVoIPRegistry() {
    let registry = PKPushRegistry(queue: DispatchQueue.main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    voipRegistry = registry
  }

  // Receive and forward the VoIP push token to the Dart layer so it can be
  // stored in Firestore and used for direct APNs VoIP delivery.
  func pushRegistry(
    _ registry: PKPushRegistry,
    didUpdate pushCredentials: PKPushCredentials,
    for type: PKPushType
  ) {
    guard type == .voIP else { return }
    let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else { return }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  // Handle incoming VoIP push when the app is killed.
  // Apple requires CXProvider.reportNewIncomingCall to be called (via the
  // plugin's showCallkitIncoming) BEFORE calling completion(), or iOS will
  // penalise the app and eventually disable VoIP push delivery.
  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else { completion(); return }

    let dict = payload.dictionaryPayload
    let callId = dict["callId"] as? String ?? UUID().uuidString
    let callerName = dict["callerName"] as? String ?? "طبيب"
    let appointmentId = dict["appointmentId"] as? String ?? ""
    let channelName = dict["agoraChannelName"] as? String
        ?? dict["channelName"] as? String ?? ""
    let agoraToken = dict["agoraToken"] as? String ?? ""
    let agoraUid = dict["agoraUid"] as? String ?? "0"

    let data = flutter_callkit_incoming.Data(
      id: callId,
      nameCaller: callerName,
      handle: "استشارة طبية",
      type: 1  // 1 = video
    )
    data.extra = [
      "appointmentId": appointmentId,
      "agoraChannelName": channelName,
      "agoraToken": agoraToken,
      "agoraUid": agoraUid,
      "callerName": callerName,
    ]

    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true) {
      completion()
    }
  }
}
