import 'codec.dart';
import 'codec_convertor.dart';

class CodecConvertors
{
   
   /// throws an exception if the conversion is already registered.
   static  void register({CodecConvertor converter, Codec from, Codec to});

   static CodecConvertor getConverter({Codec from, Codec to});

   static List<CodecConvertor>  get converters;

}