package com.example.minimal_example

class Utils {
    companion object {
        private val HEX_CHARS = "0123456789ABCDEF"
        fun hexStringToByteArray(data: String) : ByteArray {

            val result = ByteArray(data.length / 2)

            for (i in 0 until data.length step 2) {
                val firstIndex = HEX_CHARS.indexOf(data[i]);
                val secondIndex = HEX_CHARS.indexOf(data[i + 1]);

                val octet = firstIndex.shl(4).or(secondIndex)
                result.set(i.shr(1), octet.toByte())
            }

            return result
        }

        private val HEX_CHARS_ARRAY = "0123456789ABCDEF".toCharArray()
        fun toHex(byteArray: ByteArray) : String {
            val result = StringBuffer()

            byteArray.forEach {
                val octet = it.toInt()
                val firstIndex = (octet and 0xF0).ushr(4)
                val secondIndex = octet and 0x0F
                result.append(HEX_CHARS_ARRAY[firstIndex])
                result.append(HEX_CHARS_ARRAY[secondIndex])
            }

            return result.toString()
        }

        fun asciiStringToByteArray(data: String): ByteArray {
            return data.toByteArray(Charsets.US_ASCII)
        }

        fun asciiStringToHex(data: String): String {
            val result = StringBuilder()
            data.forEach {
                val hex = it.code.toString(16).padStart(2, '0')
                result.append(hex)
            }
            return result.toString().uppercase()
        }

        fun toAscii(byteArray: ByteArray): String {
            return byteArray.toString(Charsets.US_ASCII)
        }

        fun hexToAscii(hex: String): String {
            val result = StringBuilder()
            for (i in 0 until hex.length step 2) {
                val str = hex.substring(i, i + 2)
                result.append(str.toInt(16).toChar())
            }
            return result.toString()
        }
    }
}