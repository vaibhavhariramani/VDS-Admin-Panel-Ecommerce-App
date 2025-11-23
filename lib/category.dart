import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:firebase_core/firebase_core.dart'; // Always needed for initialization
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:firebase_auth/firebase_auth.dart'; // For Authentication
import 'package:firebase_storage/firebase_storage.dart'; // For Cloud Storage
import 'package:ecom_admin_panel/models/data_provider.dart';

import 'componds/imagess.dart';

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ScrollController _view = ScrollController();
  TextEditingController name = TextEditingController();
  TextEditingController tag = TextEditingController();
  TextEditingController index = TextEditingController();
  TextEditingController sunname = TextEditingController();
  late PickedFile? category;
  late PickedFile? icon;
  late StateSetter _setState;
  final _picker = ImagePickerPlugin();
  List<dynamic> sub = [];

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Container(
          child: Column(
        children: [
          SizedBox(height: 20),
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 5, right: 8, left: 8, bottom: 5),
                    child: Text("Category",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87)),
                  ),
                  Container(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add New',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          _addCategory();
                        }),
                  ),
                ]),
          ),
          SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
              stream: dataProvider.category(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      controller: _view,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4.5,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (snapshot.hasData) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          // Safely get the tags list
                          List<dynamic> tagsList = [];
                          if (doc.data() != null) {
                            final data = doc.data() as Map<String, dynamic>;
                            tagsList =
                                data.containsKey('tags') ? data['tags'] : [];
                          }
                          return customlist(doc);
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
        ],
      )),
    );
  }

  Widget customlist(DocumentSnapshot snapshot) {
  List<dynamic> tagsList = [];
  if (snapshot.data() != null) {
    final data = snapshot.data() as Map<String, dynamic>;
    tagsList = data.containsKey('tags') ? data['tags'] : [];
  }

  return Card(
    elevation: 2,
    margin: EdgeInsets.all(8),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image section - responsive height
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.2, // 20% of screen height
            child: MyImage(imageUrl: snapshot['image']),
          ),
          
          // Content section - flexible
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category info row
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.08, // 8% of screen width
                        height: MediaQuery.of(context).size.width * 0.08,
                        child: MyImage(imageUrl: snapshot['icon']),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${snapshot['name']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.02, // Responsive font
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _addSub(snapshot.id, tagsList);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Tags section - flexible
                  Expanded(
                    child: tagsList.isEmpty
                        ? Center(
                            child: Text(
                              'No sub-categories',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: tagsList.length,
                            itemBuilder: (_, i) => ListTile(
                              dense: true,
                              leading: Container(
                                width: MediaQuery.of(context).size.width * 0.06,
                                height: MediaQuery.of(context).size.width * 0.06,
                                child: MyImage(imageUrl: tagsList[i]['image']),
                              ),
                              title: Text(
                                tagsList[i]['name'].toString(),
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.015,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text("tag :$i"),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded),
                                onPressed: () {},
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  _addCategory() {
    showDialog(
        context: context,
        builder: (
          context,
        ) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                _setState = setState;
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: ListView(
                      children: [
                        SizedBox(height: 8),
                        Center(
                          child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Text("Add Category Details",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87))),
                        ),
                        DottedBorder(
                          child: GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.2,
                              color: Colors.black12,
                              child: category != null
                                  ? Image.network(category!.path)
                                  : Icon(Icons.image),
                            ),
                            onTap: () {
                              _startFilePicker();
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        DottedBorder(
                          child: GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.2,
                              color: Colors.black12,
                              child: icon != null
                                  ? Image.network(icon!.path)
                                  : Icon(Icons.image),
                            ),
                            onTap: () {
                              _startIconPicker();
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black38,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              controller: name,
                              autofocus: false,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black38,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              autofocus: false,
                              controller: index,
                              decoration: InputDecoration(
                                hintText: 'Index',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ADD',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onPressed: () {
                            _upload();
                          },
                        )
                      ],
                    ),
                  ),
                );
              }));
        });
  }

  _startFilePicker() async {
    final im =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    _setState(() {
      category = im!;
    });
    setState(() {});
  }

  _startIconPicker() async {
    final im =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    _setState(() {
      icon = im!;
    });
    setState(() {});
  }

  Future _upload() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.amber,
          ),
        );
      },
      barrierDismissible: false,
    );

    try {
      final filePath = 'category/${DateTime.now()}.png';
      final iconPath = 'icon/${DateTime.now()}.png';

      String categoryUrl;
      String iconUrl;

      if (category != null && icon != null) {
        // Read both files as bytes
        Uint8List? categoryBytes = await category?.readAsBytes();
        Uint8List? iconBytes = await icon?.readAsBytes();

        // Upload category image
        final categoryRef = FirebaseStorage.instance.ref().child(filePath);

        final categoryUploadTask = categoryRef.putData(
          categoryBytes!,
          SettableMetadata(contentType: 'image/png'),
        );

        final categorySnapshot = await categoryUploadTask;
        categoryUrl = await categorySnapshot.ref.getDownloadURL();

        // Upload icon image
        final iconRef = FirebaseStorage.instance.ref().child(iconPath);

        final iconUploadTask = iconRef.putData(
          iconBytes!,
          SettableMetadata(contentType: 'image/png'),
        );

        final iconSnapshot = await iconUploadTask;
        iconUrl = await iconSnapshot.ref.getDownloadURL();

        // Save to Firestore
        if (categoryUrl != null && iconUrl != null) {
          CollectionReference reference =
              FirebaseFirestore.instance.collection('Category');

          await reference.doc().set({
            'index': index.text,
            'name': name.text,
            'tag': name
                .text, // Note: you're using name.text twice, maybe you meant tag.text?
            'icon': iconUrl,
            'image': categoryUrl,
          });

          // Clear form
          setState(() {
            index.text = '';
            name.text = '';
            tag.text = '';
            icon = null;
            category = null;
          });
        }
      }

      Navigator.pop(context); // Close the dialog
    } catch (onError) {
      Navigator.pop(context); // Close the dialog on error too
      print('Error uploading: $onError');
    }
  }

  _addSub(String document, List<dynamic> s) {
    showDialog(
        context: context,
        builder: (
          context,
        ) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              _setState = setState;
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      SizedBox(height: 8),
                      Center(
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text("Add Sub Category",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87))),
                      ),
                      SizedBox(height: 8),
                      DottedBorder(
                        child: GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.2,
                            color: Colors.black12,
                            child: icon != null
                                ? Image.network(icon!.path)
                                : Icon(Icons.image),
                          ),
                          onTap: () {
                            _startIconPicker();
                          },
                        ),
                      ),
                      SizedBox(height: 4),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          // margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black38, width: 2),
                              borderRadius: BorderRadius.circular(20)),
                          child: TextFormField(
                            controller: sunname,
                            autofocus: false,
                            decoration: InputDecoration(
                                hintText: 'sub category',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(
                                    20.0, 10.0, 20.0, 10.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'ADD Sub Category',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (s != null) {
                            setState(() {
                              sub = List.from(s);
                            });
                          }
                          _uploadSub(document);
                        },
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  Future _uploadSub(String document) async {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.amber,
        ),
      );
    },
    barrierDismissible: false,
  );

  try {
    CollectionReference tags = FirebaseFirestore.instance.collection('Tags');
    final iconPath = 'icon/${DateTime.now()}.png';
    String iconUrl;

    if (icon != null) {
      // Read icon file as bytes
      Uint8List iconBytes = await icon!.readAsBytes();
      
      // Upload icon to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child(iconPath);
      
      final uploadTask = ref.putData(
        iconBytes,
        SettableMetadata(contentType: 'image/png'),
      );
      
      final taskSnapshot = await uploadTask;
      iconUrl = await taskSnapshot.ref.getDownloadURL();
      
      // Create tag data
      var v = {'name': sunname.text, 'image': iconUrl};
      
      // Update local sub list
      sub.add(v);
      
      // Add to Tags collection
      await tags.doc().set(v);
      
      // Update Category document - ensure tags field exists
      CollectionReference reference =
          FirebaseFirestore.instance.collection('Category');
      
      // First, get the current document to check if tags field exists
      DocumentSnapshot docSnapshot = await reference.doc(document).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        
        if (data != null && data.containsKey('tags')) {
          // Tags field exists, add to it
          await reference.doc(document).update({
            'tags': FieldValue.arrayUnion([v]),
          });
        } else {
          // Tags field doesn't exist, create it
          await reference.doc(document).update({
            'tags': [v]
          });
        }
      }
      
      // Clear form
      setState(() {
        sunname.text = '';
        icon = null;
      });
    }
    
    Navigator.pop(context); // Close the dialog
    
  } catch (error) {
    Navigator.pop(context); // Close the dialog on error
    print('Error uploading subcategory: $error');
  }
}

  _deleteCategory(String name) {
    showDialog(
        context: context,
        builder: (
          context,
        ) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        Center(
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                  "Are you sure do you want to delete ${name}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87))),
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: Container(
                            padding: EdgeInsets.only(left: 6, right: 6),
                            margin: EdgeInsets.all(6),
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(116, 116, 191, 1.0),
                                  Color.fromRGBO(52, 138, 199, 1.0)
                                ]),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.transparent, width: 0)),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  highlightColor:
                                      Theme.of(context).highlightColor,
                                  splashColor: Theme.of(context).splashColor,
                                  child: Center(
                                    child: Text(
                                      "delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  onTap: () {}),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }));
        });
  }

  _deleteSub(String name) {
    showDialog(
        context: context,
        builder: (
          context,
        ) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8),
                    Center(
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                              "Are you sure do you want to delete \n $name ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87))),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(left: 6, right: 6),
                        margin: EdgeInsets.all(6),
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(116, 116, 191, 1.0),
                              Color.fromRGBO(52, 138, 199, 1.0)
                            ]),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.transparent, width: 0)),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              highlightColor: Theme.of(context).highlightColor,
                              splashColor: Theme.of(context).splashColor,
                              child: Center(
                                child: Text(
                                  "delete",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              onTap: () {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
