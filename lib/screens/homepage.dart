import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<String>>? listData;
  bool isCircularProgressIndicatorEnable = false;
  bool isImagePicked = false;

  Future<void> _pickImage() async {
    try {
      setState(() {
        isCircularProgressIndicatorEnable = true;
        isImagePicked = false;
      });
      ImagePicker picker = ImagePicker();
      var pickedImage = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        isCircularProgressIndicatorEnable = false;
      });
      if (pickedImage != null) {
        procesImage(pickedImage.path);
        setState(() {
          isImagePicked = true;
        });
        print("Image selected");
      } else {
        _showMessage("image not selected");
      }
    } catch (e) {
      setState(() {
        isCircularProgressIndicatorEnable = false;
      });
      _showMessage("An error occurred while picking the image.: $e");
    }
  }

  Future<void> procesImage(String path) async {
    try {
      InputImage inputImage = InputImage.fromFilePath(path);

      TextRecognizer textRecognizer = TextRecognizer();

      RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      var extractedText = recognizedText.text;

      // print(extractedText);
      parseExtractedData(extractedText);
    } catch (e) {
      _showMessage("An error occurred while processing the image: $e");
    }
  }

  parseExtractedData(String extractedText) {
    List<String> lines = extractedText.split("\n");

    List<List<String>> row = [];

    List<String> code = [];
    List<String> title = [];
    List<String> fullAsstMarks = [];
    List<String> fullFinalMarks = [];
    List<String> passAsstMarks = [];
    List<String> passFinalMarks = [];
    List<String> asstMarksObtained = [];
    List<String> finalMarksObtained = [];
    List<String> total = [];
    List<String> remarks = [];

    bool codeSection = false;
    bool titleSection = false;
    bool fullAsstMarksSection = false;
    bool fullFinalMarksSection = false;
    bool passAsstMarksSection = false;
    bool passFinalMarksSection = false;
    bool asstMarksObtainedSection = false;
    bool finalMarksObtainedSection = false;
    bool totalSection = false;
    bool remarksSection = false;

    List<String> tempList = [];

    for (var line in lines) {
      line = line.trim();
      if (line.contains("Code")) {
        codeSection = true;
        continue;
      } else if (line.contains("Title")) {
        codeSection = false;
        titleSection = true;
        continue;
      } else if (line.contains("Asst. FinalAsst. Final Asst.")) {
        titleSection = false;
        fullAsstMarksSection = true;
        fullFinalMarksSection = true;
        passAsstMarksSection = true;
        passFinalMarksSection = true;

        asstMarksObtainedSection = true;
        continue;
      } else if (line.contains("Final")) {
        fullFinalMarksSection = false;
        passAsstMarksSection = false;
        passFinalMarksSection = false;
        asstMarksObtainedSection = false;
        fullAsstMarksSection = false;
        finalMarksObtainedSection = true;
        continue;
      } else if (line.contains("Total")) {
        finalMarksObtainedSection = false;
        totalSection = true;

        continue;
      } else if (line.contains("Remarks")) {
        totalSection = false;
        remarksSection = true;
        continue;
      }

      if (codeSection) {
        code.add(line);
      } else if (titleSection) {
        title.add(line);
      } else if (finalMarksObtainedSection) {
        finalMarksObtained.add(line);
      } else if (fullAsstMarksSection == true ||
          fullFinalMarksSection == true ||
          passAsstMarksSection == true ||
          passFinalMarksSection == true ||
          asstMarksObtainedSection == true) {
        tempList.add(line);
      } else if (remarksSection) {
        remarks.add(line);
      } else if (totalSection) {
        total.add(line);
      }
    }

    if (title.length > 4) {
      title[3] = title[3] + title[4];
      title.removeAt(4);
    }
    if (title.length > 6) {
      title[4] = title[5] + title[6];
      title.removeAt(5);
    }

    List<String> nFinalMarksObtained = [];
    int nfinalMobtain = 0;

    for (int i = 0; i < 10; i++) {
      if (i == 1 || i == 4 || i == 5 || i == 6) {
        nFinalMarksObtained.add("-");
      } else {
        if (nfinalMobtain < finalMarksObtained.length) {
          nFinalMarksObtained.add(finalMarksObtained[nfinalMobtain]);
          nfinalMobtain++;
        } else {
          nFinalMarksObtained.add("");
        }
      }
    }

    int indexOb = 0;
    int countElement = 0;

    for (int i = 0; i < 50; i++) {
      if (countElement < 10) {
        if (indexOb < tempList.length) {
          fullAsstMarks.add(tempList[indexOb]);
          indexOb++;
        } else {
          fullAsstMarks.add("-");
        }
        countElement++;
      } else if (countElement < 20) {
        if (countElement == 11 ||
            countElement == 14 ||
            countElement == 15 ||
            countElement == 16) {
          fullFinalMarks.add("-");
        } else {
          if (indexOb < tempList.length) {
            fullFinalMarks.add(tempList[indexOb]);
            indexOb++;
          } else {
            fullFinalMarks.add("-");
          }
        }
        countElement++;
      } else if (countElement < 30) {
        if (indexOb < tempList.length) {
          passAsstMarks.add(tempList[indexOb]);
          indexOb++;
        } else {
          passAsstMarks.add("-");
        }
        countElement++;
      } else if (countElement < 40) {
        if (countElement == 31 ||
            countElement == 34 ||
            countElement == 35 ||
            countElement == 36) {
          passFinalMarks.add("-");
        } else {
          if (indexOb < tempList.length) {
            passFinalMarks.add(tempList[indexOb]);
            indexOb++;
          } else {
            passFinalMarks.add("-");
          }
        }
        countElement++;
      } else if (countElement < 50) {
        if (indexOb < tempList.length) {
          asstMarksObtained.add(tempList[indexOb]);
          indexOb++;
        } else {
          asstMarksObtained.add("-");
        }
        countElement++;
      }
    }

    for (int i = 0; i < 10; i++) {
      row.add([
        i < 10
            ? i == 9
                ? "SH453"
                : code[i]
            : "",
        i < title.length ? title[i] : "",
        i < fullAsstMarks.length ? fullAsstMarks[i] : "",
        i < fullFinalMarks.length ? fullFinalMarks[i] : "",
        i < passAsstMarks.length ? passAsstMarks[i] : "",
        i < passFinalMarks.length ? passFinalMarks[i] : "",
        i < asstMarksObtained.length ? asstMarksObtained[i] : "-",
        i < nFinalMarksObtained.length ? nFinalMarksObtained[i] : "-",
        i < total.length ? total[i] : "-",
        i < remarks.length ? remarks[i] : ""
      ]);
    }

    listData = row;

    saveInCsvFormat(row);
    setState(() {});
  }

  saveInCsvFormat(List<List<String>> row) async {
    String csv = const ListToCsvConverter().convert(row);

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = "${appDocumentsDir.path}/marksheet.csv";

    File file = File(path);
    await file.writeAsString(csv);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  SingleChildScrollView _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(children: [
          DataTable(columns: buildSubHeader(), rows: []),
          DataTable(
              dividerThickness: 2.0,
              columns: buildHeader(),
              rows: listData!.map((eachRow) {
                return DataRow(
                    cells: eachRow.map((cell) {
                  return DataCell(Text(cell));
                }).toList());
              }).toList()),
        ]),
      ),
    );
  }

  Center buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.scanner,
            size: 120,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _pickImage();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Upload Marksheet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white)),
              )),
          const SizedBox(
            height: 15,
          ),
          isCircularProgressIndicatorEnable
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 4,
                  ),
                )
              : const Text("")
        ],
      ),
    );
  }

  buildIndicators() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.black,
          ),
          const Text(
            "Just a moment, extracting data...",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ],
      ),
    );
  }

  List<DataColumn> buildHeader() {
    return const [
      DataColumn(label: Text('Code')),
      DataColumn(label: Text('Title')),
      DataColumn(label: Text('Asst.')),
      DataColumn(label: Text('Final')),
      DataColumn(label: Text('Asst.')),
      DataColumn(label: Text('Final ')),
      DataColumn(label: Text('Asst.')),
      DataColumn(label: Text('Final')),
      DataColumn(label: Text('Total')),
      DataColumn(label: Text('Remarks')),
    ];
  }

  List<DataColumn> buildSubHeader() {
    return const [
      DataColumn(
          label: Text(
        "Subjects",
        style: TextStyle(decoration: TextDecoration.underline),
      )),
      DataColumn(label: Text("")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("Full marks")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("Pass marks")),
      DataColumn(label: Text("")),
      DataColumn(label: Text("Marks obtained")),
      DataColumn(label: Text("")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Scanner App",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: listData != null
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildDataTable(),
            )
          : isImagePicked
              ? buildIndicators()
              : buildInitialView(),
    );
  }
}
