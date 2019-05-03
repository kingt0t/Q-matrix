package im.pattle.app

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.push.PushService

class Application : FlutterApplication(), PluginRegistrantCallback {
  override fun onCreate() {
    super.onCreate();
    PushService.setPluginRegistrant(this)
  }

  override fun registerWith(registry: PluginRegistry) {
    GeneratedPluginRegistrant.registerWith(registry)
  }
}