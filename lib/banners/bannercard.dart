import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/models/firebase.service.dart';

class BannerCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String id;
  const BannerCard({Key? key, required this.data, required this.id})
      : super(key: key);

  @override
  _BannerCardState createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _hasError
            ? _buildErrorPlaceholder()
            : _buildCachedNetworkImage(),
        IconButton(
          icon: Icon(Icons.delete_outline_rounded),
          onPressed: () {
            deleteBanner(widget.id);
          },
        ),
      ],
    );
  }

  Widget _buildCachedNetworkImage() {
    return CachedNetworkImage(
      imageUrl: widget.data['image'],
      cacheKey: '${widget.data['image']}_${DateTime.now().millisecondsSinceEpoch}',
      memCacheWidth: 500,
      memCacheHeight: 300,
      maxWidthDiskCache: 500,
      maxHeightDiskCache: 300,
      filterQuality: FilterQuality.low,
      httpHeaders: {
        'Accept': 'image/*',
        'Cache-Control': 'no-cache',
      },
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        print('Image load error: $error for URL: $url');
        print('Error type: ${error.runtimeType}');
        
        // Set error state and rebuild
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
        
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }



  deleteBanner(String name) {
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
                                  style: const TextStyle(
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
                                gradient: const LinearGradient(colors: [
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
                                  child: const Center(
                                    child: Text(
                                      "delete",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  onTap: () {
                                    InsertDatainFirebase().DeleteBanner(name);
                                    Navigator.of(context).pop();
                                  }),
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
}
