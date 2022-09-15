import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget? _loadingDialog;
  var dio = Dio();
  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    print(statuses[Permission.storage]);
  }

  showLoading({BuildContext? dialogContext}) {
    if (_loadingDialog == null) {
      _loadingDialog = Center(
        child: SizedBox(
          child: const CircularProgressIndicator(
            color: Colors.red,
          ),
          height: 100,
          width: 100,
        ),
      );
      showDialog(
          barrierDismissible: false,
          context: dialogContext ?? context,
          builder: (_) =>
              _loadingDialog ??
              Container(
                color: Colors.transparent,
              ));
    }
  }

  hideLoading({BuildContext? dialogContext}) {
    if (_loadingDialog != null) {
      Navigator.pop(dialogContext ?? context);
      _loadingDialog = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test screen')),
      body: Center(
        child: InkWell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(Colors.red.value),
            ),
            height: 40,
            width: 100,
            child: Text("Open File"),
          ),
          onTap: () async {
            var tempDir = await getTemporaryDirectory();
            String fullPath = "${tempDir.path}/output.zip";
            print('full path ${fullPath}');
            final zipFile = File(fullPath);
            final outputHtml = File("${tempDir.path}/output.html");
            bool isExistHtml = await outputHtml.exists();
            if (isExistHtml) {
              OpenFile.open(outputHtml.path);
            } else {
              showLoading();
              bool isExistFileZip = await zipFile.exists();
              if (!isExistFileZip) {
                await download2(
                    dio, "http://trans-crew-dev.dkiv.vn/output.zip", fullPath);
              }
              try {
                await ZipFile.extractToDirectory(
                    zipFile: zipFile, destinationDir: tempDir);
              } catch (e) {
                print(e);
              }
              hideLoading();
              OpenFile.open(outputHtml.path);
            }
          },
        ),
      ),
    );
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: showDownloadProgress,
      );
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
