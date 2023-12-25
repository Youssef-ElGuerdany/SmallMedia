import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user_infos.dart';
import 'package:fluttershare/screens/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final UserInfos? currentUser; // Make currentUser nullable
  const Upload({Key? key, required this.currentUser}) : super(key: key);

  @override
  UploadState createState() => UploadState();
}

class UploadState extends State<Upload> {
  final timestamp = DateTime.now();

  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  XFile? file;
  bool isUploading = false;
  String postId = const Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: handleTakePhoto,
                  child: const Text("Photo with Camera")),
              SimpleDialogOption(
                  onPressed: handleChooseFromGallery,
                  child: const Text("Image from Gallery")),
              SimpleDialogOption(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  Future<void> compressImage() async {
    final temporaryDirectory = await getTemporaryDirectory();
    final path = temporaryDirectory.path;

    if (file != null) {
      final imageFile = img.decodeImage(File(file!.path).readAsBytesSync());

      if (imageFile != null) {
        final compressedImageFile = File('$path/img_$postId.jpg')
          ..writeAsBytesSync(img.encodeJpg(imageFile, quality: 85));

        setState(() {
          file = XFile(compressedImageFile.path);
        });

        debugPrint(
            'Image compressed and saved to: ${compressedImageFile.path}');
      } else {
        debugPrint('Error decoding image');
      }
    } else {
      debugPrint('No image selec ted');
    }
  }

  Future<String> uploadImage(XFile xFile) async {
    // Convert XFile to File 
    File imageFile = File(xFile.path);
    var storageRef = FirebaseStorage.instance.ref().child('post_$postId.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() => debugPrint('Upload Complete'));

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  createPostInFireStore(
      {required String mediaUrl,
      required String location,
      required String description}) {
    postsRef
        .doc(widget.currentUser!.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser!.id,
      'username': widget.currentUser!.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {}
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file!);
    createPostInFireStore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
  }

  SizedBox buildSplashScreen() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
                child: const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                onPressed: () => selectImage(context)),
          ),
        ],
      ),
    );
  }

Future<void> getUserLocation() async {
  try {
    // Request location permissions if not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark? placemark = placemarks.isNotEmpty ? placemarks[0] : null;

      if (placemark != null) {
        String formattedAddress = '${placemark.country}  ${placemark.locality}';
        debugPrint(formattedAddress);
        locationController.text = formattedAddress;
      } else {
        debugPrint('No placemark found');
      }
    } else {
      debugPrint('Location permission denied');
    }
  } catch (e) {
    debugPrint('Error getting user location: $e');
  }
}

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            onPressed: clearImage, icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: isUploading ? null : () => handleSubmit(),
              child: const Text(
                'post',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : const Text(''),
          SizedBox(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover, image: FileImage(File(file!.path)))),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                    hintText: 'Write a Caption ...', border: InputBorder.none),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                    hintText: 'Where was this photo taken',
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 50.0,
            color: Colors.orange,
            alignment: Alignment.center,
            child: InkWell(
              onTap: getUserLocation,
              child: const Text('Use current location'),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
