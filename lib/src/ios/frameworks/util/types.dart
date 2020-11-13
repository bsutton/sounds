import 'dart:ffi';

///Types ending in Arg are used to make the value passed in's address accessible
///
///equates to UInt32 *ioDataSize
class Uint32Arg extends Struct {
  @Uint32()
  final int value;
  Uint32Arg(this.value);

//get address as a Uint32 instead of Uint32Arg
  Pointer<Uint32> get addressOfNative =>
      Pointer<Uint32>.fromAddress(addressOf.address);
}

///equates to void *outPropertyData
class VoidArg extends Struct {
  //get address as a Void(ffi) instead of void
  Pointer<Void> get addressOfNative =>
      Pointer<Void>.fromAddress(addressOf.address);
}
