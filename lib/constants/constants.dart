import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

const String noImg =
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/600px-No_image_available.svg.png";

String dateFortter1(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

String dateFortter2(DateTime value) => DateFormat('dd MMM, yyyy').format(value);

String dateFortter3(DateTime value) => DateFormat('dd/MM/yy').format(value);

String timeFormatter(DateTime value) => DateFormat('h:mm a').format(value);

const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

const String phonePattern = r'(^[0-9]{10}$)';

const String passwordPattern = r"^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$";

RegExp numberFormatterRegex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

String Function(Match) get formatNumberCount => (Match match) => '${match[1]},';

Color kPrimaryColor = Color.fromARGB(255, 129, 255, 118);

/// The single place to change the public storefront domain per
/// environment. A published shop's URL is `$storefrontBaseUrl/{shopId}` —
/// the Client App (hosted at local-bazaar-shop.web.app) routes directly by
/// a shop's own Firestore doc id, e.g. `.../#/store/4N6v2VdoJ4RmyWJ57ADG`.
/// There's no separate code-to-shop lookup today; a vanity/custom code is
/// a possible later feature, not the current mechanism.
const String storefrontBaseUrl = 'https://local-bazaar-shop.web.app/#/store';

enum Option { step1, step2 }
