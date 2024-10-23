import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../locator.dart';
import '../../../service/service.dart';
import '../../../util/util.dart';
import '../../ui.dart';
import 'dart:io';
import 'package:path/path.dart' show extension;

class UploadPaymentConfirmationView extends StatefulWidget {
  final String? salesOrderNumber;
  final String? requestReferenceCode;
  const UploadPaymentConfirmationView({Key? key, required this.salesOrderNumber, required this.requestReferenceCode})
      : super(key: key);

  @override
  State<UploadPaymentConfirmationView> createState() => _UploadPaymentConfirmationViewState();
}

class _UploadPaymentConfirmationViewState extends State<UploadPaymentConfirmationView> {
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController remarkTextEditingController = TextEditingController();
  late FileUploadController controller;
  List<String> extensions = ["jpg", "jpeg", "png", "pdf", "docx"];
  List<File> uploadedFiles = [];
  List<Uploads> uploadedFilesNames = [];

  @override
  void initState() {
    controller = locate<FileUploadController>();
    super.initState();
  }

  handleBrowse(Source source) async {
    late File? file;
    try {
      locate<LoadingIndicatorController>().show();

      file = await pickFile(source, extensions: extensions);
      if (file == null) return null;

      String fileExtension = extension(file.path);
      if (!extensions.any((ext) => ext == fileExtension.substring(1))) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Extension is not supported",
            subtitle: "Extension: $fileExtension is not supported",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      if (file.lengthSync() > 5e+6) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "File is too large",
            subtitle: "File size is larger than 5MB",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      if (uploadedFiles.length >= 5) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "File limit reached",
            subtitle: "You can upload up to 5 files.",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }

      final result = await locate<RestService>().fileUpload(await fileToBase64(file));
      if (result == null) throw Exception();

      String path = await locate<RestService>().getFullFilePath(result);
      controller.setValue(controller.value.copyWith(
        fileImagePath: path,
        document: result,
        fileName: result,
      ));
      setState(() {
        uploadedFiles.add(file ?? File(''));
        uploadedFilesNames.add(Uploads(documentName: result));
      });
    } catch (error) {
      rethrow;
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  void removeFile(String file) {
    int index = uploadedFilesNames.indexOf(uploadedFilesNames.firstWhere((element) => element.documentName == file));
    if (index != -1) {
      setState(() {
        uploadedFiles.removeAt(index);
        uploadedFilesNames.removeAt(index);
      });
    }
  }

  void previewFile(String documentId) async {
    try {
      String path = await locate<RestService>().getFullFilePath(documentId);
      await launchUrl(Uri.parse(path));
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 2),
      );
    }
  }

  Future<void> unblockRequestWithSlip(List<Uploads> uploads) async {
    List<Map<String, dynamic>> uploadList = uploads.map((uploads) {
      return {
        "documentName": uploads.documentName,
      };
    }).toList();

    try {
      if (remarkTextEditingController.text.isEmpty) {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Remarks is required",
            subtitle: "Please enter remarks",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
        return;
      }
      locate<LoadingIndicatorController>().show();
      await locate<RestService>().unblockRequestWithSlip(
        uploadList: uploadList,
        requestReferenceCode: widget.requestReferenceCode,
        remarks: remarkTextEditingController.text,
        type: "SLIP",
      );
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Payment Slips Submit Successfully",
          subtitle: "Successfully submitted payment slips",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      GoRouter.of(context).push("/view-sales-orders");
    } catch (e) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<LoadingIndicatorController>().hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithTM(),
      body: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, snapshot, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 110,
                  color: const Color(0xFF4A7A36).withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Upload Payment Confirmation",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4A7A36)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "For : ${widget.salesOrderNumber}",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4A7A36)),
                        ),
                        const Divider(
                          color: Color(0xFF4A7A36),
                          height: 20,
                          thickness: 2,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Upload your payment confirmation. Allowed\nfiles: PDF, Docx, Png, Jpg with maximum file size\n5MB.",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF929292),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: remarkTextEditingController,
                            autocorrect: false,
                            onChanged: (value) {},
                            maxLines: 3,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                              hintText: 'Remarks..',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: InkWell(
                          onTap: () {
                            handleBrowse(Source.files);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: paymentAmountController,
                                  autocorrect: false,
                                  onChanged: (value) {},
                                  textAlign: TextAlign.left,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    hintText: 'Select File',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  bottom: -6,
                                  right: -6,
                                  child: SizedBox(
                                    width: 120,
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      color: const Color(0xFFD7D7D7),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Browse",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (uploadedFiles.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "Selected Files:",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF929292),
                                  ),
                            ),
                            const SizedBox(height: 5),
                            for (Uploads upload in uploadedFilesNames)
                              Row(
                                children: [
                                  const SizedBox(width: 18),
                                  TextButton(
                                    onPressed: () {
                                      previewFile(upload.documentName ?? ''); // Pass the document ID here
                                    },
                                    child: Text((() {
                                      final fullText = upload.documentName!.split('/').last;
                                      return fullText.length > 18 ? '${fullText.substring(0, 18)}..' : fullText;
                                    })(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: const Color(0xFF000000),
                                            )),
                                  ),
                                  IconButton(
                                    onPressed: () => removeFile(upload.documentName!),
                                    icon: const Icon(Icons.remove_circle_outlined, size: 20, color: Colors.grey),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UploadPaymentConfirmationButton(
                              onPressed: () {
                                unblockRequestWithSlip(uploadedFilesNames);
                              },
                            ),
                            UploadPaymentCancelButton(onPressed: () {
                              Navigator.of(context).pop();
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class UploadPaymentConfirmationButton extends StatelessWidget {
  final void Function()? onPressed;

  const UploadPaymentConfirmationButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width >= 360 ? 160 : 130,
        height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(const Color(0xFF4A7A36)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            elevation: MaterialStateProperty.all(3),
          ),
          child: Text(
            "Upload",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class UploadPaymentCancelButton extends StatelessWidget {
  final void Function()? onPressed;

  const UploadPaymentCancelButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width >= 360 ? 160 : 130,
        height: MediaQuery.of(context).size.width >= 360 ? 50 : 40,
        child: FilledButton(
          onPressed: onPressed,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
            backgroundColor: MaterialStateProperty.all(Colors.grey),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            elevation: MaterialStateProperty.all(3),
          ),
          child: Text(
            "Cancel",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class FileUploadValue {
  String? fileImagePath;
  String? document;
  String? fileName;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  FileUploadValue.empty();

  FileUploadValue copyWith({
    String? fileImagePath,
    String? document,
    String? fileName,
    Map<String, String>? errors,
  }) {
    return FileUploadValue.empty()
      ..fileImagePath = fileImagePath ?? this.fileImagePath
      ..document = document ?? this.document
      ..fileName = fileName ?? this.fileName
      ..errors = errors ?? this.errors;
  }
}

class FileUploadController extends FormController<FileUploadValue> {
  FileUploadController() : super(initialValue: FileUploadValue.empty());

  clear() {
    value = FileUploadValue.empty();
  }
}

class Uploads {
  String? documentName;

  Uploads({
    this.documentName,
  });
}
