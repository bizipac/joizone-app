import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/plvender_model.dart';

class PlVendorService {
  static const String apiUrl =
      "https://fms.bizipac.com/apinew/pl/fetch_pl_vendor_master.php";

  static Future<List<PlVendorModel>> fetchVendors() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == 1) {
        List list = jsonData['data'];
        return list.map((e) => PlVendorModel.fromJson(e)).toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception("Server Error");
    }
  }
}
