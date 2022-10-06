import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:loadweb/platform_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';

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
    loadData();
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

  showAlertDialog(BuildContext context) async {
    await NAlertDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Text("Alert"),
      content: Text("Internet not connected"),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ).show(context);
  }

  loadData() async {
    String fullPath = "";
    Directory? tempDir;
    tempDir = await getTemporaryDirectory();
    fullPath = "${tempDir.path}/$zipName";
    // print('full path ${fullPath}');

    final zipFile = File(fullPath);
    final outputHtml = File("${tempDir.path}/$htmlName");
    bool isExistHtml = await outputHtml.exists();
    if (isExistHtml) {
      openFile(outputHtml.path);
    } else {
      showLoading();
      bool isExistFileZip = await zipFile.exists();
      if (!isExistFileZip) {
        try {
          final result = await InternetAddress.lookup('example.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            await download2(dio, linkDownload, fullPath);
            try {
              await ZipFile.extractToDirectory(
                  zipFile: zipFile, destinationDir: tempDir);
            } catch (e) {
              // print(e);
            }
            openFile(outputHtml.path);
          }
        } on SocketException catch (_) {
          hideLoading();
          showAlertDialog(context);
        }
      } else {
        try {
          print('zipbbb');
          await ZipFile.extractToDirectory(
              zipFile: zipFile, destinationDir: tempDir);
        } catch (e) {
          // print(e);
        }
        openFile(outputHtml.path);
      }
      hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/images/icon.png",
            fit: BoxFit.contain,
            height: 100,
            width: 140,
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_sp2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  height: 40,
                  width: 100,
                  child: Text(
                    "Download file",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () async {
                  loadData();
                },
              ),
            )
          ],
        ));
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
