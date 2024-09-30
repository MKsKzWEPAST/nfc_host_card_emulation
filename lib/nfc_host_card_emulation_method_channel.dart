import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';

import 'nfc_host_card_emulation_platform_interface.dart';

/// An implementation of [NfcHostCardEmulationPlatform] that uses method channels.
class MethodChannelNfcHostCardEmulation extends NfcHostCardEmulationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nfc_host_card_emulation');

  @override
  Future<void> init(
    dynamic args,
    StreamController<NfcApduCommand> streamController,
  ) async {
    await methodChannel.invokeMethod('init', args);

    methodChannel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case 'apduCommand':
            final args = call.arguments;
            final int port = args['port'];
            final Uint8List command = args['command'];
            Uint8List? data = args['data'];
            if (data?.isEmpty ?? true) data = null;

            developer.log(
              'Received APDU command on port $port: ${command.map((e) => e.toRadixString(16))}'
              '.${data == null ? '' : '\nAdditional data in command: ${data.map((e) => e.toRadixString(16))}'}',
              name: 'NFC_HCE',
            );

            streamController.add(NfcApduCommand(port, command, data));
            break;
        }
      },
    );
  }


  @override
  Future<NfcState> checkDeviceNfcState() async {
    final state = await methodChannel.invokeMethod<bool?>('checkNfc');
    switch (state) {
      case true:
        return NfcState.enabled;
      case false:
        return NfcState.disabled;
      default:
        return NfcState.notSupported;
    }
  }

  @override
  Future<String> getHello() async {
    return await methodChannel.invokeMethod('getHello');
  }

  @override
  Future<void> setHello(String hello) async {
    await methodChannel.invokeMethod('setHello', {'hello': hello});
  }

  @override
  Future<void> setJsonArrayByte(Uint8List jsonArrayByte) async {
    await methodChannel.invokeMethod('setJsonArrayByte', {'jsonArrayByte': jsonArrayByte});
  }

  @override
  Future<Uint8List> getJsonArrayByte() async {
    return await methodChannel.invokeMethod('getJsonArrayByte');
  }
}
