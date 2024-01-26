// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/misc/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';

class JobDescriptionEditor extends StatefulWidget {
  @override
  _JobDescriptionEditorState createState() => _JobDescriptionEditorState();
}

class _JobDescriptionEditorState extends State<JobDescriptionEditor> {
  final quillController = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add job description'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.check),
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
