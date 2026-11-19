import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/pg_controller.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class TenantFormScreen extends StatefulWidget {
  const TenantFormScreen({
    super.key,
    this.tenant,
    this.presetBedId,
  });

  final Tenant? tenant;
  final String? presetBedId;

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final pg = Get.find<PgController>();
  final _form = GlobalKey<FormState>();

  late final _name = TextEditingController(
    text: widget.tenant?.name,
  );
  late final _phone = TextEditingController(
    text: widget.tenant?.phone,
  );
  late final _rent = TextEditingController(
    text: widget.tenant?.monthlyRent.toStringAsFixed(0),
  );
  late final _deposit = TextEditingController(
    text: widget.tenant?.deposit.toStringAsFixed(0),
  );
  late String? _bedId = widget.tenant?.bedId ?? widget.presetBedId;
  late final Map<String, String> _docs = {
    ...?widget.tenant?.documents,
  };

  bool _saving = false;
  bool get _editing => widget.tenant != null;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _rent, _deposit]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(String label) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      setState(() => _docs[label] = file.path);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    final bed = pg.beds.firstWhere((bed) => bed.id == _bedId);
    final tenant = Tenant(
      id: widget.tenant?.id ?? 't${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      roomId: bed.roomId,
      bedId: bed.id,
      monthlyRent: double.parse(_rent.text.trim()),
      deposit: double.parse(_deposit.text.trim()),
      documents: Map.of(_docs),
    );

    if (_editing) {
      await pg.updateTenant(tenant);
    } else {
      await pg.addTenant(tenant);
    }

    if (!mounted) return;
    Get.back();
    toast(
      _editing ? 'Updated' : 'Done',
      _editing ? 'Tenant details saved' : '${tenant.name} added',
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _number(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Enter a number' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit tenant' : 'New tenant'),
      ),
      body: Obx(() {
        final beds = pg.beds
            .where(
              (bed) => bed.vacant || bed.id == widget.tenant?.bedId,
            )
            .toList();

        return Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.length != 10) {
                          return 'Enter 10 digits';
                        }

                        final duplicate = pg.tenants.any(
                          (tenant) =>
                              tenant.phone == phone &&
                              tenant.id != widget.tenant?.id,
                        );

                        return duplicate
                            ? 'Number already used by another tenant'
                            : null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue:
                          beds.any((bed) => bed.id == _bedId) ? _bedId : null,
                      validator: (value) =>
                          value == null ? 'Select a bed' : null,
                      decoration: InputDecoration(
                        labelText: 'Bed (${pg.vacantBeds.length} vacant)',
                        prefixIcon: const Icon(Icons.bed_outlined),
                      ),
                      items: beds
                          .map(
                            (bed) => DropdownMenuItem(
                              value: bed.id,
                              child: Text(
                                'Room ${pg.roomById(bed.roomId)?.number}'
                                ' - Bed ${bed.label}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _bedId = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rent,
                            keyboardType: TextInputType.number,
                            validator: _number,
                            decoration: const InputDecoration(
                              labelText: 'Monthly rent',
                              prefixText: '\u20B9 ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _deposit,
                            keyboardType: TextInputType.number,
                            validator: _number,
                            decoration: const InputDecoration(
                              labelText: 'Deposit',
                              prefixText: '\u20B9 ',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SectionTitle('Documents (optional)'),
              for (final label in ['ID proof (Aadhaar)', 'Photo'])
                AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  onTap: () => _pick(label),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _docs.containsKey(label)
                          ? Icons.check_circle
                          : Icons.upload_file,
                      color: _docs.containsKey(label)
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(label),
                    subtitle: Text(
                      _docs[label]?.split('/').last ?? 'Tap to upload',
                    ),
                    trailing: _docs.containsKey(label)
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => _docs.remove(label));
                            },
                          )
                        : null,
                  ),
                ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_editing ? 'Save changes' : 'Add tenant'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
