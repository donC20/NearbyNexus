// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously, unused_element, avoid_print

import 'dart:convert';

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/providers/common_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class JobDescriptionEditor extends StatefulWidget {
  final bool isOpenforEdit;

  const JobDescriptionEditor({Key? key, required this.isOpenforEdit})
      : super(key: key);

  @override
  _JobDescriptionEditorState createState() => _JobDescriptionEditorState();
}

class _JobDescriptionEditorState extends State<JobDescriptionEditor> {
  final quillController = quill.QuillController.basic();
  String htmlContent = '';

  var logger = Logger();
  bool _isDataLoading = false;

  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    if (widget.isOpenforEdit) {
      loadFromPrefs();
    }
    _speech = stt.SpeechToText();
  }

  Future<void> loadFromPrefs() async {
    setState(() {
      _isDataLoading = true;
    });
    String? html = await UtilityFunctions()
        .fetchFromSharedPreference("descriptionController");
    logger.e('html value is $html');
    if (html != null) {
      List<Map<String, dynamic>> delta = Document.fromHtml(html)
          .toJson()
          .toList() as List<Map<String, dynamic>>;
      quillController.document = quill.Document.fromJson(delta);
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    quillController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commonProvider = Provider.of<CommonProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Warning'),
                content: quillController.document.isEmpty()
                    ? Text('Do you want to exit?')
                    : Text(
                        'You have unsaved changes. Do you want to discard them?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Discard changes
                    },
                    child: Text('Discard'),
                  ),
                  quillController.document.isEmpty()
                      ? TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Stay on the page
                          },
                          child: Text('Stay'),
                        )
                      : TextButton(
                          onPressed: () async {
                            if (quillController.document.isEmpty()) {
                              UtilityFunctions().showSnackbar(
                                "Hmmm.. Description seems to be empty.",
                                Colors.red,
                                context,
                              );
                            } else {
                              final deltaOps = quillController.document
                                  .toDelta()
                                  .toJson()
                                  .toList() as List<Map<String, dynamic>>;
                              final converter = QuillDeltaToHtmlConverter(
                                deltaOps,
                                ConverterOptions.forEmail(),
                              );
                              final html = converter.convert();

                              bool isSaved = await UtilityFunctions()
                                  .sharedPreferenceCreator(
                                      "descriptionController", html);
                              if (isSaved) {
                                commonProvider.changeDescriptionBtnState(true);
                                UtilityFunctions().showSnackbar(
                                    "Data Saved!", Colors.green, context);
                              } else {
                                commonProvider.changeDescriptionBtnState(false);
                                UtilityFunctions().showSnackbar(
                                    "Unable to save data :)",
                                    Colors.red,
                                    context);
                              }
                            }

                            Navigator.of(context).pop(true); // Stay on the page
                          },
                          child: Text('Save & exit'),
                        ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
        appBar: AppBar(
          title: Text('Add job description'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed: () async {
                  if (quillController.document.isEmpty()) {
                    UtilityFunctions().showSnackbar(
                      "Hmmm.. Description seems to be empty.",
                      Colors.red,
                      context,
                    );
                  } else {
                    final deltaOps = quillController.document
                        .toDelta()
                        .toJson()
                        .toList() as List<Map<String, dynamic>>;
                    final converter = QuillDeltaToHtmlConverter(
                      deltaOps,
                      ConverterOptions.forEmail(),
                    );
                    final html = converter.convert();

                    bool isSaved = await UtilityFunctions()
                        .sharedPreferenceCreator("descriptionController", html);
                    if (isSaved) {
                      commonProvider.changeDescriptionBtnState(true);
                      UtilityFunctions()
                          .showSnackbar("Data Saved!", Colors.green, context);
                    } else {
                      commonProvider.changeDescriptionBtnState(false);
                      UtilityFunctions().showSnackbar(
                          "Unable to save data :)", Colors.red, context);
                    }
                  }
                },
                icon: Icon(Icons.check),
              ),
            ),
          ],
        ),
        body: _isDataLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("Please wait..")
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    QuillToolbar.simple(
                      configurations: QuillSimpleToolbarConfigurations(
                        controller: quillController,
                        toolbarIconAlignment: WrapAlignment.spaceBetween,
                      ),
                    ),
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
              ),
      ),
    );
  }

  // void _listen() async {
  //   if (!_isListening) {
  //     bool available = await _speech?.initialize(
  //           onStatus: (val) => print('onStatus: $val'),
  //           onError: (val) => print('onError: $val'),
  //         ) ??
  //         false;

  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech?.listen(
  //         onResult: (val) {
  //           setState(() {
  //             if (_speech != null) {

  //             }
  //           });
  //         },
  //       );
  //     } else {
  //       print('Speech recognition not available');
  //     }
  //   } else {
  //     setState(() => _isListening = false);
  //     _speech?.stop();
  //   }
  // }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech!.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech?.listen(
          onResult: (val) {
            setState(() {
              quillController.document.insert(
                quillController.selection.end,
                val.recognizedWords,
              );
            });
          },
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      setState(() => _isListening = false);
      _speech?.stop();
    }
  }
}
