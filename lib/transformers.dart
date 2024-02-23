library transformers;

import 'dart:async';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

typedef ConsoleMessageCallback = dynamic Function(
    ConsoleMessage consoleMessage);
typedef LoadStartCallback = void Function(String url);
typedef LoadStopCallback = void Function(String url);
typedef ModelLoadSuccessCallback = void Function(dynamic modelLoadedResult);
typedef ModelLoadFailedCallback = void Function(dynamic errorResult);

class Transformers {
  static Transformers? _instance;
  static Transformers get instance {
    _instance ??= Transformers._(); // Create instance if it doesn't exist
    return _instance!;
  }

  Function? onUpdateCallback;
  Function? onModelLoadSucess;
  Function? onModelLoadFailed;
  Function? onRunSuccess;
  Function? onRunFailed;
  Function? onStringTypeError;
  Function? onProgressCallbackNotAllowed;

  InAppWebViewController? _webViewController;
  HeadlessInAppWebView? _headlessWebView;
  late StreamController<ConsoleMessage> _consoleMessageController;

  Transformers._() {
    // _consoleMessageController = StreamController<ConsoleMessage>.broadcast();

    // Call the initialization method in the constructor
    _headlessWebView?.dispose();
    _init();
  }

  Map<String, dynamic> currentMessage = {};
  bool isTransformersLoaded = false;
  Future<void> _init() async {
    if (_headlessWebView == null) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
      }

      _headlessWebView = HeadlessInAppWebView(
        initialUrlRequest:
            URLRequest(url: WebUri("https://fluttertransformer.web.app?x#i=1")),
        initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
        onProgressChanged: (controller, progress) {
          print("\n\nPROGRESS -> $progress");
        },
        onWebViewCreated: (controller) {},
        onConsoleMessage: (controller, consoleMessage) {
          try {
            currentMessage = convertToJSONObject(consoleMessage.message);
          } catch (err) {
            //do nothing
          }

          if (currentMessage['status'] == 'modelLoaded') {
            onModelLoadSucess?.call();
          } else if (currentMessage['status'] == 'modelLoadFailed') {
            onModelLoadFailed?.call();
          }
          onUpdateCallback?.call();
          //_consoleMessageController.add(consoleMessage);
        },
        onLoadStart: (controller, url) async {},
        onLoadStop: (controller, url) async {
          isTransformersLoaded = true;
        },
      );
      await _headlessWebView?.run();
    } else {
      _headlessWebView = _headlessWebView;
    }
  }

  InAppWebViewController? get transformers =>
      _headlessWebView?.webViewController;
  get logs => currentMessage;
  void makefalse() {
    isTransformersLoaded = !isTransformersLoaded;
    print("changed $isTransformersLoaded");
    onUpdateCallback?.call();
  }

  dynamic convertToJSONObject(String latestConsoleMessage) {
    try {
      // Try parsing the message as JSON

      return jsonDecode(latestConsoleMessage);
    } catch (error) {
      print(error);
      // If parsing fails, return the original message
      return latestConsoleMessage;
    }
  }

  Future<dynamic> pipeline(
    String task,
    String name,
    Map<String, dynamic>? options,
  ) async {
    // final consoleMessageSubscription =
    //     consoleMessagesStream.listen((consoleMessage) {
    //   //  if (consoleMessage.type == ConsoleMessageType.progress) {
    //   onProgress(jsonDecode(consoleMessage.message));
    // });

    try {
      await _headlessWebView?.webViewController?.evaluateJavascript(
        source: """loadModel("$task","$name",${jsonEncode(options)})""",
      );
    } finally {
      // Cancel the subscription after the evaluation is completed or if an error occurs
      //consoleMessageSubscription?.cancel();
    }
  }

  Future<dynamic> runPipeline(
    String modelId,
    dynamic data,
    Map<String, dynamic>? options,
    List<dynamic> additionalParameters,
  ) async {
    String jsFunctionCall;

    if (additionalParameters.isEmpty) {
      jsFunctionCall = """
    runModel(
      "$modelId",
      ${jsonEncode(data)},
      ${jsonEncode(options)}
    )
    """;
    } else {
      jsFunctionCall = """
    runModel(
      "$modelId",
      ${jsonEncode(data)},
      ${jsonEncode(options)},
      ${additionalParameters.map((param) => jsonEncode(param)).toList()}
    )
    """;
    }

    try {
      await _headlessWebView?.webViewController?.evaluateJavascript(
        source: jsFunctionCall,
      );
    } finally {
      // Clean-up logic here if needed
    }
  }

  Future<dynamic> getListOfPipelines() async {
    var listOfmodels = await _headlessWebView?.webViewController
        ?.evaluateJavascript(source: """(()=>{
          return pipeline;
        })()""");
    print(listOfmodels);
    return listOfmodels;
  }

  ConsoleMessageCallback _updateState(
    ConsoleMessageCallback callback,
  ) {
    return callback;
  }
}
