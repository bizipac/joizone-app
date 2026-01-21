import 'package:flutter/material.dart';
import 'package:joizone_app/view/webview_screen.dart';

import '../controller/pl_vender_controller.dart';
import '../model/plvender_model.dart';
import '../utils/app_constent.dart';

class CreateLead extends StatefulWidget {
  final String userid;
  const CreateLead({super.key,required this.userid});

  @override
  State<CreateLead> createState() => _CreateLeadState();
}

class _CreateLeadState extends State<CreateLead> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String mobile;
  late String name;

  List<PlVendorModel> vendorList = [];
  PlVendorModel? selectedVendor;
  bool loading = true;

  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadVendors();
  }
  void loadVendors() async {
    try {
      final data = await PlVendorService.fetchVendors();
      setState(() {
        vendorList = data;
        loading = false;
      });
    } catch (e) {
      loading = false;
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Lead")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          mobile = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter your mobile';
                          } else {
                            return null;
                          }
                        },
                        // 👈 use state variable
                        decoration: InputDecoration(
                          labelText: 'Mobile no',
                          labelStyle: TextStyle(
                            color: AppConstant.appTextDarkColor,
                            fontSize: 15,
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppConstant.borderColor,
                            ), // border when not focused
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppConstant.borderColor,
                              width: 2.0,
                            ), // border when focused
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          name = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter your name';
                          } else {
                            return null;
                          }
                        },
                        // 👈 use state variable
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: AppConstant.appTextDarkColor,
                            fontSize: 15,
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppConstant.borderColor,
                            ), // border when not focused
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppConstant.borderColor,
                              width: 2.0,
                            ), // border when focused
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<PlVendorModel>(
                        decoration: const InputDecoration(
                          labelText: "Select Product Type",
                          border: OutlineInputBorder(),
                        ),
                        items: vendorList.map((vendor) {
                          return DropdownMenuItem(
                            value: vendor,
                            child: Text(
                                "${vendor.productType} - ${vendor.vendorName}"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedVendor = val;

                            final baseUrl = val?.predefinedLink ?? "";

                            urlController.text = baseUrl.isNotEmpty
                                ? "$baseUrl/userid=${widget.userid}"
                                : "";
                          });

                        },
                      ),

                      const SizedBox(height: 20),

                      /// 🔗 URL TextBox
                      TextFormField(
                        controller: urlController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Predefined Link",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: selectedVendor == null
                      //       ? null
                      //       : () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) =>
                      //             WebViewScreen(url: selectedVendor!.predefinedLink),
                      //       ),
                      //     );
                      //   },
                      //   child: const Text("OPEN APPLICATION"),
                      // ),


                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
