import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'helen Cloud Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'helen Cloud Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _controllerSentence;
  String sentenceInput = "";
  late TextEditingController _controllerLanguage;
  String languageInput = "";
  late VideoPlayerController _controllerVideo;
  String urlVideoCloud = "";

  static const List<double> _playbackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];
  int _indexPlaybackRate = 2;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Missing Params'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Sentence and/or Language input(s) cannot be empty.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> postRequest(String sentence, String language) async {
    print(sentence);
    print(language);

    if (sentence.isEmpty || language.isEmpty) {
      _showMyDialog();
      return "";
    }
    try {
      var url = Uri.parse('https://34.148.239.128:8080');

      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
        },
        body: {'sentence': sentence, 'language': language},
      );

      print('Response body: ${response.body}');

      return response.body;
    } catch (e) {
      return "https://storage.googleapis.com/helen-render-storage/helen32388.mp4";
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerSentence = TextEditingController();
    _controllerLanguage = TextEditingController();
    _controllerVideo = VideoPlayerController.network('')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controllerSentence.dispose();
    _controllerLanguage.dispose();
    _controllerVideo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ProgressHUD(
        child: Builder(builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: _controllerSentence,
                      onChanged: (String value) {
                        sentenceInput = value;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type sentence to convert',
                        prefixIcon: Icon(
                          Icons.text_fields,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                    width: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: _controllerLanguage,
                      onChanged: (String value) {
                        languageInput = value;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type sentence to convert',
                        prefixIcon: Icon(
                          Icons.language,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      urlVideoCloud =
                          await postRequest(sentenceInput, languageInput);
                      if (urlVideoCloud.contains("https")) {
                        final _progress = ProgressHUD.of(context);
                        _progress?.showWithText('Loading Video...');
                        _controllerVideo =
                            VideoPlayerController.network(urlVideoCloud)
                              ..initialize().then((_) {
                                _progress?.dismiss();
                                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                setState(() {
                                  _controllerVideo.play();
                                });
                                _controllerVideo.addListener(() {
                                  final progress = ProgressHUD.of(context);
                                  setState(() {
                                    _controllerVideo.value.isPlaying;
                                  });
                                  if (_controllerVideo.value.isBuffering) {
                                    progress?.showWithText('Buffering...');
                                  } else {
                                    progress?.dismiss();
                                  }
                                });
                              });
                      } else {
                        setState(() {
                          _controllerVideo = VideoPlayerController.network('')
                            ..initialize().then((_) {
                              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                              setState(() {});
                            });
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.cloud_upload,
                      size: 62.0,
                    ),
                  ),
                  Visibility(
                    visible:
                        _controllerVideo.value.isInitialized ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controllerVideo.value.aspectRatio,
                          child: VideoPlayer(_controllerVideo),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Visibility(
          visible: _controllerVideo.value.isInitialized ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _controllerVideo = VideoPlayerController.network('')
                  ..initialize().then((_) {
                    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                    setState(() {});
                  });
              });
            },
            child: const Icon(Icons.delete_forever_outlined),
          ),
        ),
        Visibility(
          visible: _controllerVideo.value.isInitialized ? true : false,
          child: const SizedBox(
            width: 5.0,
            height: 5.0,
          ),
        ),
        Visibility(
          visible: _controllerVideo.value.isInitialized ? true : false,
          child: FloatingActionButton.extended(
            onPressed: () {
              _indexPlaybackRate += 1;
              if (_indexPlaybackRate >= _playbackRates.length) {
                _indexPlaybackRate = 0;
              }
              _controllerVideo
                  .setPlaybackSpeed(_playbackRates[_indexPlaybackRate]);
            },
            icon: const Icon(Icons.shutter_speed),
            label: Text(_playbackRates[_indexPlaybackRate].toString()),
          ),
        ),
        Visibility(
          visible: _controllerVideo.value.isInitialized ? true : false,
          child: const SizedBox(
            width: 5.0,
            height: 5.0,
          ),
        ),
        Visibility(
          visible: _controllerVideo.value.isInitialized ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _controllerVideo.value.isPlaying
                    ? _controllerVideo.pause()
                    : _controllerVideo.play();
              });
            },
            child: Icon(
              _controllerVideo.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ),
      ]),
    );
  }
}
