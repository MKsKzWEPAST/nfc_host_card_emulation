import 'dart:async';
import 'dart:typed_data';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation_platform_interface.dart';

class NfcHce {
  static NfcHostCardEmulationPlatform get _platform =>
      NfcHostCardEmulationPlatform.instance;
  static final _apduController = StreamController<NfcApduCommand>.broadcast();

  /// The stream that will notify about the received APDU commands.
  /// Listen to it and do some action.
  static Stream<NfcApduCommand> get stream => _apduController.stream;

  /// Initializes the HCE with the specified parameters:
  /// - `aid`: AID for connection. Must be a Uint8List with a length from 5 to 16
  /// and match at least one aid-filter in apduservice.xml.
  /// - `permanentApduResponses`: determines whether APDU responses from the ports
  /// on which the connection occurred will be deleted. If `true`, responses will be deleted, otherwise won't.
  /// - `listenOnlyConfiguredPorts`: determines whether APDU commands received on ports
  /// to which there are no responses will be added to the stream. If `true`, command won't be added, otherwise will.
  static Future<void> init({
    required Uint8List aid,
    required String hello,
    required Uint8List jsonArrayByte,
  }) async {
    if (aid.length > 16 || aid.length < 5) {
      throw "AID length exception. Length must be from 5 to 16";
    }
    await _platform.init(
      {
        'aid': aid,
        'hello': hello,
        'jsonArrayByte': jsonArrayByte,
      },
      _apduController,
    );
  }


  /// Checks device's NFC state
  static Future<NfcState> checkDeviceNfcState() async {
    return await _platform.checkDeviceNfcState();
  }

  static Future<String> getHello() async {
    return await _platform.getHello();
  }

  static Future<void> setHello(String hello) async {
    await _platform.setHello(hello);
  }

  static Future<void> setJsonArrayByte(Uint8List jsonArrayByte) async {
    await _platform.setJsonArrayByte(jsonArrayByte);
  }

  static Future<Uint8List> getJsonArrayByte() async {
    return await _platform.getJsonArrayByte();
  }
}

/// A class that contains data about accepted APDU commands.
class NfcApduCommand {
  /// The port that the APDU command came to.
  final int port;

  /// A list containing the following APDU command's fields:
  /// CLA, INS, P1, P2, AID_Length, AID
  final Uint8List command;

  /// A list containing additional data that comes after AID.
  /// If null, no additional data has been added.
  final Uint8List? data;

  const NfcApduCommand(this.port, this.command, this.data);
}

/// Enum for representing different states of an NFC device.
enum NfcState {
  enabled,
  disabled,
  notSupported,
}
