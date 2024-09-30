import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nfc_host_card_emulation_method_channel.dart';

abstract class NfcHostCardEmulationPlatform extends PlatformInterface {
  /// Constructs a NfcHostCardEmulationPlatform.
  NfcHostCardEmulationPlatform() : super(token: _token);

  static final Object _token = Object();

  static NfcHostCardEmulationPlatform _instance =
      MethodChannelNfcHostCardEmulation();

  /// The default instance of [NfcHostCardEmulationPlatform] to use.
  ///
  /// Defaults to [MethodChannelNfcHostCardEmulation].
  static NfcHostCardEmulationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NfcHostCardEmulationPlatform] when
  /// they register themselves.
  static set instance(NfcHostCardEmulationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the HCE with the specified parameters
  Future<void> init(
    dynamic args,
    StreamController<NfcApduCommand> streamController,
  );


  /// Checks device's NFC state
  Future<NfcState> checkDeviceNfcState();

  Future<String> getHello();

  Future<void> setHello(String hello);

  Future<void> setJsonArrayByte(Uint8List jsonArrayByte);

  Future<Uint8List> getJsonArrayByte();
}
