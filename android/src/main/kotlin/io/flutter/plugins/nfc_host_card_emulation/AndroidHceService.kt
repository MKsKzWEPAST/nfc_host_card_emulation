package io.flutter.plugins.nfc_host_card_emulation

import android.util.Log

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.content.Intent

class AndroidHceService: HostApduService() {

  companion object {
    var hello = "Not Working"
    val TAG = "Host Card Emulator"
    val STATUS_SUCCESS = "9000"
    val STATUS_FAILED = "6F00"
    val CLA_NOT_SUPPORTED = "6E00"
    val INS_NOT_SUPPORTED = "6D00"
    val AID = "A0000002471001"
    val SELECT_INS = "A4"
    val DEFAULT_CLA = "00"
    val MIN_APDU_LENGTH = 12

    var permanentApduResponses = false;
    var listenOnlyConfiguredPorts = false;

    var aid = byteArrayOf(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    var cla : Byte = 0
    var ins : Byte = 0xA4.toByte()

    var portData = mutableMapOf<Int, ByteArray>()


    public fun byteArrayToString(array: ByteArray) : String
    {
      var str = "["
      for(i in 0..array.size - 2)
        str += " ${array[i].toUByte().toString(16)},"
      str += " ${array[array.size - 1].toUByte().toString(16)} ]"

      return str
    }
  }



  override fun onDeactivated(reason: Int) {
    Log.d(TAG, "Deactivated: $reason")
  }

  override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray {
    if (commandApdu == null) {
      Log.d(TAG, "Received null APDU")
      return Utils.hexStringToByteArray(STATUS_FAILED)
    }

    print("Received APDU: $commandApdu")
    val hexCommandApdu = Utils.toHex(commandApdu)
    Log.d(TAG, "Received APDU: $hexCommandApdu")

    if (hexCommandApdu.length < MIN_APDU_LENGTH) {
      Log.d(TAG, "Invalid APDU: $hexCommandApdu")
      return Utils.hexStringToByteArray(STATUS_FAILED)
    }

    val cla = hexCommandApdu.substring(0, 2)
    val ins = hexCommandApdu.substring(2, 4)
    val data = hexCommandApdu.substring(10)

    // Check for correct CLA
    if (cla != DEFAULT_CLA) {
      Log.d(TAG, "CLA not supported")
      return Utils.hexStringToByteArray(CLA_NOT_SUPPORTED)
    }

    when (ins) {
      SELECT_INS -> {
        return nfcConnection(data)
      }
      "01" -> {
        return transferName(data)
      }
      else -> {
        Log.d(TAG, "INS not supported")
        return Utils.hexStringToByteArray(INS_NOT_SUPPORTED)
      }
    }

    /*
    Log.d('HCE', "Received APDU in kotlin: $commandApdu")
    val port : Int = commandApdu[3].toUByte().toInt()

    val responseApdu = portData[port]
    Intent().also { intent ->
        intent.setAction("apduCommand")
        intent.putExtra("port", port)
        intent.putExtra("command", commandApdu.copyOfRange(0, aid.size + 5))
        intent.putExtra("data", commandApdu.copyOfRange(aid.size + 5, commandApdu.size))
        sendBroadcast(intent);
    }
    if (responseApdu == null)
        return Utils.hexStringToByteArray(STATUS_FAILED)

    return responseApdu// + SUCCESS
     */
  }

  private fun nfcConnection(data: String): ByteArray {
    android.util.Log.d(TAG, "Selecting application")
    if (data.startsWith(AID)) {
      Log.d(TAG, "Application selected")
      return Utils.hexStringToByteArray(Utils.asciiStringToHex("Hello from HCE"))
    } else {
      Log.d(TAG, "AID not supported")
      return Utils.hexStringToByteArray(STATUS_FAILED)
    }
  }

  private fun transferName(data: String): ByteArray {
    if (data == Utils.asciiStringToHex("Name?")) {
      Log.d(TAG, "Name query received")
      return Utils.hexStringToByteArray(Utils.asciiStringToHex(hello))
    } else {
      Log.d(TAG, "Unexpected data in Name query")
      return Utils.hexStringToByteArray(STATUS_FAILED)
    }
  }
}