package io.flutter.plugins.nfc_host_card_emulation

import android.util.Log

import android.nfc.NfcAdapter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.content.BroadcastReceiver

import io.flutter.plugins.nfc_host_card_emulation.AndroidHceService

/** NfcHostCardEmulationPlugin */
class NfcHostCardEmulationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var activity: Activity
  private lateinit var channel : MethodChannel
  private var nfcAdapter : NfcAdapter? = null

  // base methods
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nfc_host_card_emulation")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activity.registerReceiver(apduServiceReciever, IntentFilter("apduCommand"))

    nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
  }

  override fun onDetachedFromActivity() {
    activity.unregisterReceiver(apduServiceReciever);
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    activity.registerReceiver(apduServiceReciever, IntentFilter("apduCommand"))
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity.unregisterReceiver(apduServiceReciever);
  }
  
  // nfc host card emulation methods
  private val apduServiceReciever = object : BroadcastReceiver() {
    override fun onReceive(contxt: Context?, intent: Intent?) {   
      when (intent?.action) {
        "apduCommand" -> channel.invokeMethod("apduCommand", mapOf(
          "port" to intent!!.getIntExtra("port", -1),
          "command" to intent!!.getByteArrayExtra("command"),
          "data" to intent!!.getByteArrayExtra("data"))
        )
      }
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "init" -> init(call, result)
      "checkNfc" -> result.success(nfcAdapter?.isEnabled())
      "getHello" -> result.success(AndroidHceService.hello)
      "setHello" -> {
        AndroidHceService.hello = call.argument<String>("hello")!!
        Log.d("Host Card Emulator", "Hello set to ${AndroidHceService.hello}.")
        result.success(null)
      }
      "getJsonArrayByte" -> result.success(AndroidHceService.jsonByteArray)
      "setJsonArrayByte" -> {
        AndroidHceService.jsonByteArray = call.argument<ByteArray>("jsonArrayByte")!!
        Log.d("Host Card Emulator", "jsonArrayByte set to ${AndroidHceService.jsonByteArray.size} bytes.")
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun init(call: MethodCall, result: Result) {
    try {

      val aid = call.argument<ByteArray>("aid");
      if(aid != null) AndroidHceService.aid = aid;


      val hello = call.argument<String>("hello")
      if(hello != null) {
        AndroidHceService.hello = hello
        Log.d("Host Card Emulator", "Hello set to $hello.")
      }else{
        Log.d("Host Card Emulator", "Hello not set.")
      }

      val jsonByteArray = call.argument<ByteArray>("jsonArrayByte")
      if (jsonByteArray != null) {
        AndroidHceService.jsonByteArray = jsonByteArray
        Log.d("Host Card Emulator", "jsonByteArray set to ${jsonByteArray.size} bytes.")
      }else{
        Log.d("Host Card Emulator", "jsonByteArray not set.")
      }

      val AID = AndroidHceService.byteArrayToString(AndroidHceService.aid)
      Log.d("HCE", "HCE initialized. AID = $AID.")
    }
    catch(e : Exception) {
      result.error("invalid method parameters", "invalid parameters in 'init' method", e)
    }

    result.success(null)
  }

}
