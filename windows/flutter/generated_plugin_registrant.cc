//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktop_multi_window/desktop_multi_window_plugin.h>
#include <desktop_window/desktop_window_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <flutter_window_close/flutter_window_close_plugin.h>
#include <fullscreen_window/fullscreen_window_plugin_c_api.h>
#include <rive_common/rive_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <thermal_printer/thermal_printer_plugin.h>
#include <video_player_win/video_player_win_plugin_c_api.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DesktopMultiWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopMultiWindowPlugin"));
  DesktopWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWindowPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  FlutterWindowClosePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWindowClosePlugin"));
  FullscreenWindowPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FullscreenWindowPluginCApi"));
  RivePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("RivePlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  ThermalPrinterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ThermalPrinterPlugin"));
  VideoPlayerWinPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VideoPlayerWinPluginCApi"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
