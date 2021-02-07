import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoHome(),
    );
  }
}

class ThumbnailRequest {
  final String video;

  const ThumbnailRequest({
    this.video,
  });
}

class ThumbnailResult {
  final Image image;
  const ThumbnailResult({this.image});
}

Future<ThumbnailResult> getThumbnail(ThumbnailRequest r) async {
  Uint8List bytes;

  ///CompleterはFutureでデータを運ぶ役割を担う
  final Completer<ThumbnailResult> completer = Completer();
  bytes = await VideoThumbnail.thumbnailData(
    video: r.video,
  );
  final _image = Image.memory(bytes);
  print(_image);
  completer.complete(ThumbnailResult(
    image: _image,
  ));
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({Key key, this.thumbnailRequest}) : super(key: key);
  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
        future: getThumbnail(widget.thumbnailRequest),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final _image = snapshot.data.image;
            return Column(
              children: [
                _image,
              ],
            );
          } else {
            return Container();
          }
        });
  }
}

class DemoHome extends StatefulWidget {
  @override
  _DemoHomeState createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final ImagePicker _picker = ImagePicker();
  GenThumbnailImage _futureImage;
  String videoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("thumbnail demo"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: (_futureImage != null) ? _futureImage : SizedBox(),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final PickedFile video =
                  await _picker.getVideo(source: ImageSource.gallery);
              setState(() {
                videoPath = video.path;
                _futureImage = GenThumbnailImage(
                  thumbnailRequest: ThumbnailRequest(
                    video: videoPath,
                  ),
                );
              });
            },
            child: Icon(Icons.photo),
            heroTag: "video picker",
          ),
          const SizedBox(
            width: 20.0,
          ),
          FloatingActionButton(
            onPressed: () async {
              final PickedFile video =
                  await _picker.getVideo(source: ImageSource.camera);
              setState(() {
                videoPath = video.path;
                _futureImage = GenThumbnailImage(
                  thumbnailRequest: ThumbnailRequest(
                    video: videoPath,
                  ),
                );
              });
            },
            child: Icon(Icons.camera_alt_outlined),
            heroTag: "video capture",
          ),
        ],
      ),
    );
  }
}
