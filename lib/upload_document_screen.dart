import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

enum DocType {
  identityDocuments,
  bankStatements,
  incomeRecords,
  expenseReceipts,
  additionalDocuments,
}

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({Key? key}) : super(key: key);

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  int? userId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController taxYearController = TextEditingController();
  final TextEditingController accountingPeriodController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  Map<DocType, List<PlatformFile>> pickedFiles = {
    DocType.identityDocuments: [],
    DocType.bankStatements: [],
    DocType.incomeRecords: [],
    DocType.expenseReceipts: [],
    DocType.additionalDocuments: [],
  };
  bool isLoading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  Future<void> pickFiles(DocType type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        pickedFiles[type] = result.files;
      });
    }
  }

  Future<void> upload() async {
    if (!_formKey.currentState!.validate() || userId == null) return;
    setState(() {
      isLoading = true;
      message = null;
    });
    try {
      List<http.MultipartFile> toMultipart(
        List<PlatformFile> files,
        String field,
      ) {
        return files
            .map(
              (file) => http.MultipartFile.fromBytes(
                field,
                file.bytes ?? [],
                filename: file.name,
              ),
            )
            .toList();
      }

      final api = ApiService();
      final response = await api.uploadDocument(
        userId: userId!,
        taxYear: taxYearController.text.trim(),
        accountingPeriod: accountingPeriodController.text.trim(),
        name: nameController.text.trim(),
        identityDocuments: toMultipart(
          pickedFiles[DocType.identityDocuments]!,
          'identity_documents[]',
        ),
        bankStatements: toMultipart(
          pickedFiles[DocType.bankStatements]!,
          'bank_statements[]',
        ),
        incomeRecords: toMultipart(
          pickedFiles[DocType.incomeRecords]!,
          'income_records[]',
        ),
        expenseReceipts: toMultipart(
          pickedFiles[DocType.expenseReceipts]!,
          'expense_receipts[]',
        ),
        additionalDocuments: toMultipart(
          pickedFiles[DocType.additionalDocuments]!,
          'additional_documents[]',
        ),
      );
      setState(() {
        isLoading = false;
        message =
            response.statusCode == 200 || response.statusCode == 202
                ? 'Upload successful!'
                : 'Upload failed: ${response.body}';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Error: $e';
      });
    }
  }

  Widget filePickerRow(DocType type, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => pickFiles(type),
              child: Text('Pick $label'),
            ),
            const SizedBox(width: 8),
            Text('${pickedFiles[type]?.length ?? 0} selected'),
          ],
        ),
        if ((pickedFiles[type]?.isNotEmpty ?? false))
          Wrap(
            children:
                pickedFiles[type]!
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(entry.value.name),
                          onDeleted: () {
                            setState(() {
                              pickedFiles[type]!.removeAt(entry.key);
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body:
          userId == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ID: $userId'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: taxYearController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Year',
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: accountingPeriodController,
                        decoration: const InputDecoration(
                          labelText: 'Accounting Period',
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      filePickerRow(
                        DocType.identityDocuments,
                        'Identity Documents',
                      ),
                      filePickerRow(DocType.bankStatements, 'Bank Statements'),
                      filePickerRow(DocType.incomeRecords, 'Income Records'),
                      filePickerRow(
                        DocType.expenseReceipts,
                        'Expense Receipts',
                      ),
                      filePickerRow(
                        DocType.additionalDocuments,
                        'Additional Documents',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : upload,
                          child:
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Upload'),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: TextStyle(
                            color:
                                message!.contains('successful')
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
