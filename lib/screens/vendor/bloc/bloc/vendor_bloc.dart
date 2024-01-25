import 'dart:async';

import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'vendor_event.dart';
part 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  VendorBloc() : super(VendorInitial()) {
    on<VendorBroadcastInitialEvent>(vendorBroadcastInitialEvent);
    on<UserPostBroadcastPageNavigateEvent>(userPostBroadcastPageNavigateEvent);
  }

  // EVENT FUNCTIONS
  // ////////////////////////////
  // initial event
  FutureOr<void> vendorBroadcastInitialEvent(
      VendorBroadcastInitialEvent event, Emitter<VendorState> emit) async {
    emit(UserPostBroadcastPageOnLoad());
    List<Map<String, dynamic>> jobPostData =
        await VendorCommonFn().fetchDouments('job_posts');
    emit(UserPostBroadcastPageSuccessState(jobData: jobPostData));
  }

  // card press event
  FutureOr<void> userPostBroadcastPageNavigateEvent(
      UserPostBroadcastPageNavigateEvent event, Emitter<VendorState> emit) {}
}
