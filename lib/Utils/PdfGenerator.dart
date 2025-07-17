import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';

Future<void> generateTripPdfReport(
  List<Map<String, dynamic>> data,
  BuildContext context,
  String totalDistance,
  String totalExpenditure,
  String userName,
  String userId,
) async {
  final pdf = pw.Document();

  void showSuccessDialog(String text, String filepath) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: "PDF Downloaded Successfully!",
          wantOneButton: false,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: CupertinoColors.activeGreen,
              ),
              SizedBox(height: 20),
              Text(text),
            ],
          ),
          onConfirmButtonPressed: () {
            Navigator.pop(context);
            OpenFile.open(filepath); // <-- Opens the file
          },
          confirmBtnText: "Open",
        );
      },
    );
  }

  if (data.isEmpty) {
    throw Exception("No data provided for the report.");
  }

  final headers = data.first.keys.toList();
  final tableData = data.map((row) => row.values.toList()).toList();

  final int vehicleIndex = headers.indexWhere(
    (h) => h.toLowerCase().contains('vehicle'),
  );
  final int distanceIndex = headers.indexWhere(
    (h) => h.toLowerCase().contains('distance'),
  );
  final int expenditureIndex = headers.indexWhere(
    (h) => h.toLowerCase().contains('expenditure'),
  );

  if (vehicleIndex == -1 || distanceIndex == -1 || expenditureIndex == -1) {
    throw Exception(
      "Missing 'Vehicle' or 'Distance' or 'Expenditure' column in data.",
    );
  }

  double totalBikeDistance = 0;
  double totalCarDistance = 0;
  double totalBikeExpenditure = 0;
  double totalCarExpenditure = 0;

  for (var row in tableData) {
    if (row.length <= vehicleIndex ||
        row.length <= distanceIndex ||
        row.length <= expenditureIndex)
      continue;

    final vehicleType = row[vehicleIndex].toString().toLowerCase();
    final distance = double.tryParse(row[distanceIndex].toString()) ?? 0;
    final expenditure = double.tryParse(row[expenditureIndex].toString()) ?? 0;

    if (vehicleType.contains('bike') || vehicleType.contains('2')) {
      totalBikeDistance += distance;
      totalBikeExpenditure += expenditure;
    } else if (vehicleType.contains('car') || vehicleType.contains('4')) {
      totalCarDistance += distance;
      totalCarExpenditure += expenditure;
    }
  }

  final int dateIndex = headers.indexWhere((h) => h.toLowerCase().contains('date'));

  String dateRangeText = '';
  if (dateIndex != -1) {
    try {
      final dates = data
          .map((row) {
        final parts = row[headers[dateIndex]].toString().split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        } else {
          throw FormatException('Invalid date format');
        }
      })
          .toList()
        ..sort();

      final firstDate = dates.first;
      final lastDate = dates.last;

      String formatDate(DateTime date) =>
          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

      dateRangeText = "${formatDate(firstDate)} to ${formatDate(lastDate)}";
    } catch (e) {
      print('❌ Error parsing dates: $e');
    }
  }


  final double totalDistanceAll = totalBikeDistance + totalCarDistance;
  final double totalExpenditureAll = totalBikeExpenditure + totalCarExpenditure;

  pdf.addPage(
    pw.MultiPage(
      margin: pw.EdgeInsets.all(24),
      build:
          (context) => [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                "Trip Log Report",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                "Summary of trip distances and expenditures",
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ),
            if (dateRangeText.isNotEmpty)
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  "Period: $dateRangeText",
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Report Details",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text("Name: $userName", style: pw.TextStyle(fontSize: 16)),
                pw.Text(
                  "Employee ID: $userId",
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Overview",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Vehicle Type
                    1: pw.FlexColumnWidth(2), // Distance
                    2: pw.FlexColumnWidth(2), // Expense
                  },
                  border: pw.TableBorder.all(color: PdfColors.grey500),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            "Vehicle Type",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            "Distance",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            "Expenditure",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bike Row
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "Bike",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "${totalBikeDistance.toStringAsFixed(2)} km",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "INR ${totalBikeExpenditure.toStringAsFixed(2)}",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    // Car Row
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "Car",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "${totalCarDistance.toStringAsFixed(2)} km",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "INR ${totalCarExpenditure.toStringAsFixed(2)}",
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    // Total Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "Total",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "${(totalBikeDistance + totalCarDistance).toStringAsFixed(2)} km",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "INR ${(totalBikeExpenditure + totalCarExpenditure).toStringAsFixed(2)}",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "Comprehensive Data Table",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600),
              // columnWidths: {
              //   for (var i = 0; i < headers.length; i++)
              //     i: const pw.FlexColumnWidth(),
              // },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.blueGrey900),
                  children: headers.map((header) {
                    // Estimate width based on character count (adjust multiplier as needed)
                    final estimatedWidth = header.length * 10.0;

                    return pw.Container(
                      width: estimatedWidth,
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                        textAlign: pw.TextAlign.start,
                      ),
                    );
                  }).toList(),
                ),

                // Data rows
                for (int i = 0; i < tableData.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                    ),
                    children:
                        tableData[i].map((cell) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              cell.toString(),
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          );
                        }).toList(),
                  ),

                // Totals row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: List.generate(headers.length, (index) {
                    final header = headers[index].toLowerCase();
                    String content = '';
                    if (header.contains('distance')) {
                      content = 'Total km: ${totalDistance}';
                    } else if (header.contains('expenditure') ||
                        header.contains('expense')) {
                      content = 'Total INR: $totalExpenditure';
                    }
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        content,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Generated on: ${DateTime.now().toString().split(' ').first}",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
    ),
  );

  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String version = androidInfo.version.release;
    // if (int.parse(version) <= 10) {
    //   try {
    //     final downloadsDir = Directory('/storage/emulated/0/Download');
    //     final file = File('${downloadsDir.path}/TripReport.pdf');
    //     await file.writeAsBytes(await pdf.save());
    //     print('✅ PDF saved to  : ${file.path}');
    //     showSuccessDialog("PDF downloaded at $file", file.path);
    //   } catch (e) {
    //     print('❌ Error saving PDF: $e');
    //   }
    // }
    if ( int.parse(version) <= 10) {
      try {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/TripReport.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        // Share fallback
        final xFile = XFile(filePath);
        await Share.shareXFiles([xFile]);

        print('✅ PDF shared from temp dir : $filePath');
      } catch (e) {
        print('❌ Error saving/sharing PDF: $e');
      }
    }
    else {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      if (status.isGranted) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        final file = File('${downloadsDir.path}/TripReport.pdf');
        await file.writeAsBytes(await pdf.save());
        print('✅ PDF saved to : ${file.path}');
        showSuccessDialog("PDF downloaded at $file", file.path);
      } else {
        print('❌ Storage permission denied.');
      }
    }
  } else if (Platform.isIOS) {
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/TripReport.pdf");
    await file.writeAsBytes(await pdf.save());
    print('✅ PDF saved to: ${file.path}');
  }
}
