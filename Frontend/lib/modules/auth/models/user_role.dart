enum UserRole {
  ADMIN,
  DOCTOR,
  RECEPTIONIST,
  LAB_TECHNICIAN,
  PHARMACIST,
  UNKNOWN,
}

// ✅ Convert String → Enum
UserRole parseRole(String? role) {
  switch (role?.trim().toUpperCase()) {
    case "ADMIN":
      return UserRole.ADMIN;
    case "DOCTOR":
      return UserRole.DOCTOR;
    case "RECEPTIONIST":
      return UserRole.RECEPTIONIST;
    case "LAB_TECHNICIAN":
      return UserRole.LAB_TECHNICIAN;
    case "PHARMACIST":
      return UserRole.PHARMACIST;
    default:
      return UserRole.UNKNOWN;
  }
}

// ✅ Convert Enum → String
String roleToString(UserRole role) {
  return role.name;
}

// ✅ NEW: Display Name (🔥 FIX FOR YOUR ERROR)
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.ADMIN:
        return "Admin";
      case UserRole.DOCTOR:
        return "Doctor";
      case UserRole.RECEPTIONIST:
        return "Receptionist";
      case UserRole.LAB_TECHNICIAN:
        return "Lab Technician";
      case UserRole.PHARMACIST:
        return "Pharmacist";
      default:
        return "User";
    }
  }
}