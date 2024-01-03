
import 'dart:convert';

import 'package:http/http.dart' as http;


//Bu işlev, bir URL parametresi alır ve bu URL'ye bir HTTP GET isteği gönderir.
//İlk olarak, url parametresi bir Uri nesnesine dönüştürülür. Bu nesne, http.get fonksiyonuna geçirilebilir.
//Daha sonra, http.get fonksiyonu ile istek gönderilir ve yanıt response değişkeninde saklanır. Bu yanıt, await anahtar kelimesi kullanılarak
// beklenir.
//Eğer yanıtın durum kodu (statusCode) 200 ise, yanıtın veri bölümü (body) bir String değişken olan Jsondata değişkeninde saklanır.
// fonksiyonu kullanılarak, Jsondata değişkenindeki JSON verisi bir decodeData değişkeninde çözümlenir ve işlev bu değişkeni döndürür.


class RequestAsistant{
  static Future<dynamic>getRequest(String url) async
  {
    Uri uri = Uri.parse(url);

   //http.get() fonksiyonunun URL yerine bir URI nesnesi bekler.

    // http.get() fonksiyonuna geçirilen url String değerini Uri.parse() fonksiyonu ile bir URI nesnesine dönüştür

http.Response response= await http.get(uri);
try{

  if(response.statusCode== 200)
  {
    String Jsondata= response.body;
    print(Jsondata);
    var decodeData= jsonDecode(Jsondata);
    print(decodeData);
    return decodeData;
  }
  else
  {
    return "failed";
  }
}
catch(exp){
 return "failed";
}
  }
}