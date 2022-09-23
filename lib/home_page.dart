import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:loadweb/platform_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'percent_loading.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget? _loadingDialog;
  var dio = Dio();
  final linkDownload = "http://trans-crew-dev.dkiv.vn/demo.zip";
  ValueNotifier<int> percent = ValueNotifier(0);
  final zipName = "demo.zip";
  final htmlName = "output.html";
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
        child: PercentLoadingDialog(percent),
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
              color: Colors.red,
            ),
            height: 40,
            width: 100,
            child: Text("Open File"),
          ),
          onTap: () async {
            String fullPath = "";
            Directory? tempDir;
            // if (Platform.isAndroid) {
            tempDir = await getTemporaryDirectory();
            // } else if (Platform.isIOS) {
            //   final tempDirPath = await PlatformChannel().getSavePath();
            //   tempDir = Directory(tempDirPath);
            // }
            fullPath = "${tempDir.path}/$zipName";
            print('full path ${fullPath}');

            final zipFile = File(fullPath);
            final outputHtml = File("${tempDir.path}/$htmlName");
            bool isExistHtml = await outputHtml.exists();
            if (isExistHtml) {
              openFile(outputHtml.path);
            } else {
              showLoading();
              bool isExistFileZip = await zipFile.exists();
              if (!isExistFileZip) {
                await download2(dio, linkDownload, fullPath);
              }
              try {
                await ZipFile.extractToDirectory(
                    zipFile: zipFile, destinationDir: tempDir);
              } catch (e) {
                print(e);
              }
              hideLoading();
              openFile(outputHtml.path);
            }
          },
        ),
      ),
    );
  }

  openFile(String path) async {
    // if (Platform.isIOS) {
    PlatformChannel().openWebView(path);
    // } else {
    //   OpenFile.open(path);
    // }
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      percent.value = 0;
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: showDownloadProgress,
      );
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(int received, int total) {
    if (total != -1) {
      percent.value = received * 100 ~/ total;
      print("${percent.value}%");
    }
  }
}
