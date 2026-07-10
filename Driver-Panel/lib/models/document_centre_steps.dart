import 'package:wavego_driver/data/vehicle_document_requirements.dart';
import 'package:wavego_driver/models/registration_model.dart';

enum DocumentStepStatus {
  completed,
  active,
  locked,
  optional,
  underVerification,
}

class DocumentCentreItem {
  const DocumentCentreItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.status,
    this.routeName,
    this.isPermissions = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final DocumentStepStatus status;
  final String? routeName;
  final bool isPermissions;
}

class DocumentCentreProgress {
  const DocumentCentreProgress._({
    required this.items,
    required this.canSubmit,
    required this.submitted,
  });

  final List<DocumentCentreItem> items;
  final bool canSubmit;
  final bool submitted;

  static DocumentCentreProgress fromRegistration(
    DriverRegistration r, {
    bool submitted = false,
    Map<String, String>? serverStepStatus,
    List<Map<String, dynamic>>? serverSteps,
  }) {
    final vehicleType = (r.vehicleType ?? '').trim();
    final vehicleTypeDone = vehicleType.isNotEmpty;

    final photoNameDone = r.fullName.trim().isNotEmpty &&
        ((r.profilePhotoUrl ?? r.selfieUrl) ?? '').trim().isNotEmpty &&
        (r.dateOfBirth ?? '').trim().isNotEmpty &&
        (r.gender ?? '').trim().isNotEmpty;

    final licenseDone = (r.licenseNumber ?? '').trim().isNotEmpty &&
        (r.licenseFrontUrl ?? '').trim().isNotEmpty;

    final vehicleNumberDone = (r.vehicleNumber ?? '').trim().isNotEmpty &&
        (r.rcUrl ?? '').trim().isNotEmpty &&
        (r.rcBackUrl ?? '').trim().isNotEmpty;

    final kycDone = (r.aadhaarFrontUrl ?? '').trim().isNotEmpty &&
        (r.aadhaarBackUrl ?? '').trim().isNotEmpty &&
        (r.aadhaarNumber ?? '').trim().isNotEmpty;

    final vehicleDocsDone = VehicleDocumentRequirements.isSatisfied(r);

    final doneById = <String, bool>{
      'vehicle': vehicleTypeDone,
      'photo_name': photoNameDone,
      'license': licenseDone,
      'vehicle_number': vehicleNumberDone,
      'kyc': kycDone,
      'vehicle_docs': vehicleDocsDone,
    };

    if (serverSteps != null) {
      for (final step in serverSteps) {
        final id = step['id'] as String?;
        if (id != null && step['completed'] == true) {
          doneById[id] = true;
        }
      }
    }

    const orderedRequired = [
      'vehicle',
      'photo_name',
      'license',
      'vehicle_number',
      'kyc',
      'vehicle_docs',
    ];

    String? activeId;
    for (final id in orderedRequired) {
      if (doneById[id] == true) continue;
      final prerequisites = orderedRequired.takeWhile((step) => step != id);
      final unlocked = prerequisites.every((step) => doneById[step] == true);
      if (unlocked) {
        activeId = id;
        break;
      }
    }

    DocumentStepStatus statusFor(String id, {bool optional = false}) {
      if (optional) return DocumentStepStatus.optional;
      final serverStatus = serverStepStatus?[id];
      if (submitted && doneById[id] == true) {
        if (serverStatus == 'under_verification') {
          return DocumentStepStatus.underVerification;
        }
        return DocumentStepStatus.completed;
      }
      if (doneById[id] == true) return DocumentStepStatus.completed;
      if (id == activeId) return DocumentStepStatus.active;
      return DocumentStepStatus.locked;
    }

    String? subtitleFor(String id, DocumentStepStatus status) {
      if (id == 'vehicle' && vehicleTypeDone) return 'Selected';
      if (id == 'vehicle_docs' && vehicleTypeDone) {
        return '$vehicleType documents';
      }
      if (status == DocumentStepStatus.underVerification) {
        return 'Under verification...';
      }
      return null;
    }

    final vehicleDocsTitle = vehicleTypeDone
        ? 'Vehicle documents ($vehicleType)'
        : 'Vehicle documents';

    final items = <DocumentCentreItem>[
      DocumentCentreItem(
        id: 'vehicle',
        title: vehicleTypeDone ? 'Vehicle - $vehicleType' : 'Vehicle',
        subtitle: subtitleFor('vehicle', statusFor('vehicle')),
        status: statusFor('vehicle'),
        routeName: 'vehicle',
      ),
      DocumentCentreItem(
        id: 'photo_name',
        title: 'Photo and name',
        subtitle: subtitleFor('photo_name', statusFor('photo_name')),
        status: statusFor('photo_name'),
        routeName: 'photo_name',
      ),
      DocumentCentreItem(
        id: 'license',
        title: 'Driving License',
        subtitle: subtitleFor('license', statusFor('license')),
        status: statusFor('license'),
        routeName: 'license',
      ),
      DocumentCentreItem(
        id: 'vehicle_number',
        title: 'Vehicle Number & RC',
        subtitle: subtitleFor('vehicle_number', statusFor('vehicle_number')),
        status: statusFor('vehicle_number'),
        routeName: 'vehicle_number',
      ),
      DocumentCentreItem(
        id: 'kyc',
        title: 'Aadhaar Card',
        subtitle: subtitleFor('kyc', statusFor('kyc')),
        status: statusFor('kyc'),
        routeName: 'kyc',
      ),
      DocumentCentreItem(
        id: 'vehicle_docs',
        title: vehicleDocsTitle,
        subtitle: subtitleFor('vehicle_docs', statusFor('vehicle_docs')),
        status: statusFor('vehicle_docs'),
        routeName: 'vehicle_docs',
      ),
      const DocumentCentreItem(
        id: 'permissions',
        title: 'Permissions (optional)',
        status: DocumentStepStatus.optional,
        isPermissions: true,
      ),
    ];

    final canSubmit =
        !submitted && orderedRequired.every((id) => doneById[id] == true);

    return DocumentCentreProgress._(
      items: items,
      canSubmit: canSubmit,
      submitted: submitted,
    );
  }
}
