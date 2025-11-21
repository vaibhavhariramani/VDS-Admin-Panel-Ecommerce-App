// import 'package:flutter/material.dart';

// Widget _buildNetworkImage(dynamic widget) {
//   return Image.network(
//     widget.data['image'],
//     fit: BoxFit.cover,
//     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//       if (loadingProgress == null) return child;
//       return Container(
//         color: Colors.grey[300],
//         child: Center(
//           child: CircularProgressIndicator(
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         ),
//       );
//     },
//     errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//       print('Image.network error: $exception');
//       print('Stack trace: $stackTrace');
      
//       WidgetsBinding.instance?.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _hasError = true;
//           });
//         }
//       });
      
//       return _buildErrorPlaceholder();
//     },
//     headers: {'Accept': 'image/*'},
//     cacheWidth: 500,
//     cacheHeight: 300,
//     filterQuality: FilterQuality.low,
//   );
// }