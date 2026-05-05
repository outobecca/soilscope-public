import Flutter
import UIKit

@main
class AppDelegate : FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    RegisterGeneratedPlugins(registry: engineBridge.pluginRegistry)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ configuration: NSConfigurationOptions) {
    super.applicationDidFinishLaunching(configuration)
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
  }

  func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
    if FlutterPluginRegistry.hasPlugin("SharedPreferencesPlugin") {
      SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"));
    }
  }
}
