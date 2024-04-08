import 'dart:ffi';

String pointerCharToDartString(Pointer<Char> pointer) {
  List<int> byteList = [];
  while (pointer[byteList.length] != 0) {
    byteList.add(pointer[byteList.length]);
  }
  String dartString = String.fromCharCodes(byteList);
  return dartString;
}
