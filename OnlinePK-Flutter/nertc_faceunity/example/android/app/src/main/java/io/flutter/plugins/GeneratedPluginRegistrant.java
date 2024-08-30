package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new com.netease.nertcflutter.NERtcCorePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin nertc_core, com.netease.nertcflutter.NERtcCorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.netease.nertcfaceunity.NERtcFaceUnityFlutterPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin nertc_faceunity, com.netease.nertcfaceunity.NERtcFaceUnityFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.packageinfo.PackageInfoPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin package_info, io.flutter.plugins.packageinfo.PackageInfoPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin permission_handler, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.netease.yunxin.alog.yunxin_alog.FlutterAlogPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin yunxin_alog, com.netease.yunxin.alog.yunxin_alog.FlutterAlogPlugin", e);
    }
  }
}
