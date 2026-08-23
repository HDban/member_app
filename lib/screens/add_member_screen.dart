import 'package:flutter/material.dart';
import '../database/db_helper.dart' as db;
import '../models/member.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _remarkController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final member = Member(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
      );

      await db.DataService.instance.createMember(member);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('会员添加成功')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加会员'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMember,
                  child: _isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
