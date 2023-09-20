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

const String apiKey = "da2-zyxxvpic2nhlfetdsnk4vznvhi";

const String graphqlEndpoint =
    "https://xiz7sjryubbtzcvgimxy7tcuem.appsync-api.eu-west-1.amazonaws.com/graphql";

Color kPrimaryColor = Color.fromARGB(255, 129, 255, 118);

enum Option { step1, step2 }
