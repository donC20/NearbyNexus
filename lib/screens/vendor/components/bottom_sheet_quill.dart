// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logger/logger.dart';
import 'package:delta_to_html/delta_to_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class JobDescriptionEditor extends StatefulWidget {
  const JobDescriptionEditor({super.key});

  @override
  _JobDescriptionEditorState createState() => _JobDescriptionEditorState();
}

class _JobDescriptionEditorState extends State<JobDescriptionEditor> {
  final quillController = quill.QuillController.basic();
  String htmlContent = '';

//
  var logger = Logger();

  @override
  void dispose() {
    super.dispose();
    quillController.dispose();
  }
  // shared preferences

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add job description'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                  onPressed: () {
                    final deltaOps = quillController.document
                        .toDelta()
                        .toJson()
                        .toList() as List<Map<String, dynamic>>;

                    final converter = QuillDeltaToHtmlConverter(
                      deltaOps,
                      ConverterOptions.forEmail(),
                    );

                    final html = converter.convert();
                    UtilityFunctions()
                        .sharedPreferenceCreator("descriptionController", html);
                  },
                  icon: Icon(Icons.check)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: quillController,
                  toolbarIconAlignment: WrapAlignment.spaceBetween,
                ),
              ), // This line adds the toolbar

              Expanded(
                child: quill.QuillEditor(
                  scrollController: ScrollController(),
                  configurations: quill.QuillEditorConfigurations(
                    controller: quillController,
                    scrollable: true,
                    autoFocus: false,
                    readOnly: false,
                    placeholder: 'Enter your job description here...',
                    expands: false,
                    padding: EdgeInsets.zero,
                    onLaunchUrl: (String url) {
                      // Handle launching URLs, if needed
                    },
                  ),
                  focusNode: FocusNode(),
                ),
              ),
            ],
          ),
        ));
  }
}
