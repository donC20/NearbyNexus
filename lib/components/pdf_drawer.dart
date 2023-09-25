// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:NearbyNexus/components/pdf_api.dart';
import 'package:NearbyNexus/models/invoice_model.dart';
import 'package:logger/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfDrawer {
  var logger = Logger();

  static Future<File?> generate(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) =>
          [buildHeader(invoice), buildTitle(), buildUser(invoice)],
      footer: (context) => footerContent(invoice),
    ));

    return PdfApi.saveDocument(name: 'invoice.pdf', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "NearbyNexus",
            style: TextStyle(
                color: PdfColors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          Divider(color: PdfColors.grey),
          SizedBox(height: 2 * PdfPageFormat.cm),
        ],
      );

  static Widget buildTitle() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "INVOICE",
            style: TextStyle(
                color: PdfColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2 * PdfPageFormat.cm),
        ],
      );

  static Widget buildUser(Invoice invoice) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Payed by", invoice.userName),
            _buildRow("Payed to", invoice.vendorName),
            _buildRow("Payed on", invoice.payDate),
            _buildRow("Service name", invoice.jobName),
            SizedBox(height: 10), // Increase space between rows
            _buildDivider(),
            _buildRow("Amount paid", invoice.amount, isAmount: true),
          ],
        ),
      );

  static Widget _buildRow(String label, String value,
          {bool isAmount = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: PdfColors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isAmount ? PdfColors.green : PdfColors.grey,
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      );

  static Widget _buildDivider() => Container(
        height: 1,
        color: PdfColors.grey,
        margin: const EdgeInsets.symmetric(vertical: 5),
      );

  static Widget footerContent(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(color: PdfColors.grey),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              invoice.invoiceId,
              style: TextStyle(
                  color: PdfColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            ),
            Text(
              invoice.printDate.toString(),
              style: TextStyle(
                  color: PdfColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            ),
          ])
        ],
      );
}
