import 'package:objectbox/objectbox.dart';

@Entity()
class DataSharingPermission {
  @Id()
  int id;

  final int ownerId; // ID Pasien (Pemilik data)
  final int accessorId; // ID Fisioterapis / Caregiver yang mengakses
  final String permittedDataType; // 'profile' | 'analytics' | 'all'
  final bool isAllowed;

  DataSharingPermission({
    this.id = 0,
    required this.ownerId,
    required this.accessorId,
    required this.permittedDataType,
    required this.isAllowed,
  });

  DataSharingPermission copyWith({
    int? id,
    int? ownerId,
    int? accessorId,
    String? permittedDataType,
    bool? isAllowed,
  }) {
    return DataSharingPermission(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      accessorId: accessorId ?? this.accessorId,
      permittedDataType: permittedDataType ?? this.permittedDataType,
      isAllowed: isAllowed ?? this.isAllowed,
    );
  }
}
