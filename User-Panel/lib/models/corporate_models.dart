/// Corporate membership for the rider app.
class CorporateMembership {
  const CorporateMembership({
    required this.isCorporateMember,
    this.companyId,
    this.companyName,
    this.companyStatus,
    this.employeeId,
    this.employeeCode,
    this.department,
    this.designation,
    this.employeeStatus,
    this.canBookCorporate = false,
  });

  final bool isCorporateMember;
  final String? companyId;
  final String? companyName;
  final String? companyStatus;
  final String? employeeId;
  final String? employeeCode;
  final String? department;
  final String? designation;
  final String? employeeStatus;
  final bool canBookCorporate;

  factory CorporateMembership.fromJson(Map<String, dynamic> json) {
    return CorporateMembership(
      isCorporateMember: json['is_corporate_member'] == true,
      companyId: json['company_id']?.toString(),
      companyName: json['company_name'] as String?,
      companyStatus: json['company_status'] as String?,
      employeeId: json['employee_id']?.toString(),
      employeeCode: json['employee_code'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      employeeStatus: json['employee_status'] as String?,
      canBookCorporate: json['can_book_corporate'] == true,
    );
  }

  static const empty = CorporateMembership(isCorporateMember: false);
}
