import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import 'colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  File _image;
  List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = prediction;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  pickimage_camera() async {
    var image = await imagepicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);

      detectimage(_image);
    }
  }

  pickimage_gallery() async {
    var image = await imagepicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);

      detectimage(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          ' Detection',
          style: TextStyle(color: AppColors.color, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            height: h,
            width: w,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                Center(
                  child: Text(
                    'powered by R',
                    style: TextStyle(color: AppColors.color, fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),
                _image != null
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              height: h * 0.60,

                              // width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Image.file(
                                _image,
                                height: h * 60.0,
                                width: w,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Text("Output",
                                style: TextStyle(
                                  color: AppColors.color,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(height: 20.0),
                            Text(
                              //   (_output[0]['label']).toString().substring(2),
                              "${_output[0]["label"].toString().substring(2)} ${(_output[0]["confidence"] * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: AppColors.color,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // _output != null
                            //     ? Text(
                            //         (_output[0]['confidence']).toString(),
                            //       )
                            //     : Text('')
                          ],
                        ),
                      )
                    : Container(
                        height: h * 0.60,

                        // width: double.infinity,
                        padding: EdgeInsets.all(15),
                        child: Image.asset(
                          'assets/placeholder.png',
                          height: h * 60.0,
                          width: w,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.contain,
                        ),
                      ),
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: h * 0.20,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: new Icon(Icons.camera),
                                  title: new Text('Camera'),
                                  onTap: () {
                                    pickimage_camera();
                                  },
                                ),
                                ListTile(
                                  leading: new Icon(Icons.album),
                                  title: new Text('Gallery'),
                                  onTap: () {
                                    pickimage_gallery();
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: Container(
                    width: w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: AppColors.color,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Center(
                        child: Text(
                          "Have you wear the mask ? Check now ",
                          style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
