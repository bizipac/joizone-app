class PlVendorModel {
  final String vendorId;
  final String vendorName;
  final String vendorCode;
  final String plType;
  final String productType;
  final String predefinedLink;
  final int apiRequired;
  final String minAmount;
  final String maxAmount;
  final String? minTenure;
  final String? maxTenure;
  final String? interestRate;
  final String? processingFee;
  final int status;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;

  PlVendorModel({
    required this.vendorId,
    required this.vendorName,
    required this.vendorCode,
    required this.plType,
    required this.productType,
    required this.predefinedLink,
    required this.apiRequired,
    required this.minAmount,
    required this.maxAmount,
    this.minTenure,
    this.maxTenure,
    this.interestRate,
    this.processingFee,
    required this.status,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlVendorModel.fromJson(Map<String, dynamic> json) {
    return PlVendorModel(
      vendorId: json['vendor_id'].toString(),
      vendorName: json['vendor_name'] ?? "",
      vendorCode: json['vendor_code'] ?? "",
      plType: json['pl_type'] ?? "",
      productType: json['product_type'] ?? "",
      predefinedLink: json['predefined_link'] ?? "",
      apiRequired: json['api_required'] ?? 0,
      minAmount: json['min_amount'] ?? "",
      maxAmount: json['max_amount'] ?? "",
      minTenure: json['min_tenure'],
      maxTenure: json['max_tenure'],
      interestRate: json['interest_rate'],
      processingFee: json['processing_fee'],
      status: json['status'] ?? 0,
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
