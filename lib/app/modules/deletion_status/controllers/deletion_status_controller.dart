import 'package:get/get.dart';

import '../../../../models/deletion_data_model.dart';

class DeletionStatusController extends GetxController {
  //TODO: Implement DeletionStatusController

  final count = 0.obs;
  final RxBool isVisible = false.obs;
  var allNotifications = [
    DeleteNotification(
        user: "May Gautier",
        action: "Inappropriate Use",
        role: "Country Admin",
        location: "USA",
        date: "Feb-14-22",
        status: "Pending"),
    DeleteNotification(
        user: "Luis Vitamin",
        action: "Inappropriate Use",
        role: "Merchant",
        location: "Gurgaon, India",
        date: "Feb-14-22",
        status: "Rejected"),
    DeleteNotification(
        user: "Ben Parker",
        action: "Inappropriate Use",
        role: "Affiliate",
        location: "Aarhus, Denmark",
        date: "Feb-14-22",
        status: "Approved"),
    DeleteNotification(
        user: "May Gautier",
        action: "Inappropriate Use",
        role: "Country Admin",
        location: "USA",
        date: "Feb-14-22",
        status: "Pending"),
    DeleteNotification(
        user: "Luis Vitamin",
        action: "Inappropriate Use",
        role: "Merchant",
        location: "Gurgaon, India",
        date: "Feb-14-22",
        status: "Rejected"),
    DeleteNotification(
        user: "Ben Parker",
        action: "Inappropriate Use",
        role: "Affiliate",
        location: "Aarhus, Denmark",
        date: "Feb-14-22",
        status: "Approved"),
    DeleteNotification(
        user: "May Gautier",
        action: "Inappropriate Use",
        role: "Country Admin",
        location: "USA",
        date: "Feb-14-22",
        status: "Pending"),
    DeleteNotification(
        user: "Luis Vitamin",
        action: "Inappropriate Use",
        role: "Merchant",
        location: "Gurgaon, India",
        date: "Feb-14-22",
        status: "Rejected"),
    DeleteNotification(
        user: "Ben Parker",
        action: "Inappropriate Use",
        role: "Affiliate",
        location: "Aarhus, Denmark",
        date: "Feb-14-22",
        status: "Approved"),
    DeleteNotification(
        user: "May Gautier",
        action: "Inappropriate Use",
        role: "Country Admin",
        location: "USA",
        date: "Feb-14-22",
        status: "Pending"),
    DeleteNotification(
        user: "Luis Vitamin",
        action: "Inappropriate Use",
        role: "Merchant",
        location: "Gurgaon, India",
        date: "Feb-14-22",
        status: "Rejected"),
    DeleteNotification(
        user: "Ben Parker",
        action: "Inappropriate Use",
        role: "Affiliate",
        location: "Aarhus, Denmark",
        date: "Feb-14-22",
        status: "Approved"),
  ].obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
