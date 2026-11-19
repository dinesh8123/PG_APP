enum Role { tenant, manager, owner }

enum ComplaintStatus { open, inProgress, resolved }

class Room {
  Room({required this.id, required this.number});

  final String id;
  final String number;

  Map<String, dynamic> toJson() => {'id': id, 'number': number};

  factory Room.fromJson(Map<String, dynamic> j) =>
      Room(id: j['id'] as String, number: j['number'] as String);
}

class Bed {
  Bed({
    required this.id,
    required this.roomId,
    required this.label,
    this.tenantId,
  });

  final String id;
  final String roomId;
  final String label;
  String? tenantId;

  bool get vacant => tenantId == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'label': label,
        'tenantId': tenantId,
      };

  factory Bed.fromJson(Map<String, dynamic> j) => Bed(
        id: j['id'] as String,
        roomId: j['roomId'] as String,
        label: j['label'] as String,
        tenantId: j['tenantId'] as String?,
      );
}

class Tenant {
  Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.roomId,
    required this.bedId,
    required this.monthlyRent,
    required this.deposit,
    this.documents = const {},
  });

  final String id;
  final String name;
  final String phone;
  final String roomId;
  final String bedId;
  final double monthlyRent;
  final double deposit;
  final Map<String, String> documents;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'roomId': roomId,
        'bedId': bedId,
        'monthlyRent': monthlyRent,
        'deposit': deposit,
        'documents': documents,
      };

  factory Tenant.fromJson(Map<String, dynamic> j) => Tenant(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        roomId: j['roomId'] as String,
        bedId: j['bedId'] as String,
        monthlyRent: (j['monthlyRent'] as num).toDouble(),
        deposit: (j['deposit'] as num).toDouble(),
        documents: Map<String, String>.from(
          (j['documents'] as Map?) ?? const {},
        ),
      );

  Tenant copyWith({
    String? name,
    String? phone,
    String? roomId,
    String? bedId,
    double? monthlyRent,
    double? deposit,
    Map<String, String>? documents,
  }) {
    return Tenant(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      deposit: deposit ?? this.deposit,
      documents: documents ?? this.documents,
    );
  }
}

class RentRecord {
  RentRecord({
    required this.id,
    required this.tenantId,
    required this.month,
    required this.amount,
    required this.dueDate,
    this.paidOn,
  });

  final String id;
  final String tenantId;
  final String month;
  double amount;
  final DateTime dueDate;
  DateTime? paidOn;

  bool get paid => paidOn != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'month': month,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'paidOn': paidOn?.toIso8601String(),
      };

  factory RentRecord.fromJson(Map<String, dynamic> j) => RentRecord(
        id: j['id'] as String,
        tenantId: j['tenantId'] as String,
        month: j['month'] as String,
        amount: (j['amount'] as num).toDouble(),
        dueDate: DateTime.parse(j['dueDate'] as String),
        paidOn:
            j['paidOn'] == null ? null : DateTime.parse(j['paidOn'] as String),
      );
}

class MeterReading {
  MeterReading({
    required this.roomId,
    required this.month,
    required this.previous,
    required this.current,
  });

  final String roomId;
  final String month;
  final int previous;
  final int current;

  int get units => current - previous;

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'month': month,
        'previous': previous,
        'current': current,
      };

  factory MeterReading.fromJson(Map<String, dynamic> j) => MeterReading(
        roomId: j['roomId'] as String,
        month: j['month'] as String,
        previous: j['previous'] as int,
        current: j['current'] as int,
      );
}

class Complaint {
  Complaint({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.status = ComplaintStatus.open,
  });

  final String id;
  final String tenantId;
  String title;
  String description;
  final DateTime createdAt;
  ComplaintStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory Complaint.fromJson(Map<String, dynamic> j) => Complaint(
        id: j['id'] as String,
        tenantId: j['tenantId'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        status: ComplaintStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => ComplaintStatus.open,
        ),
      );
}

class MenuDay {
  const MenuDay(this.day, this.breakfast, this.lunch, this.dinner);

  final String day;
  final String breakfast;
  final String lunch;
  final String dinner;
}
