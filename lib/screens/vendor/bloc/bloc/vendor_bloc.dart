// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';

import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'vendor_event.dart';
part 'vendor_state.dart';


////////////////////////////////////////////////////////////////////////////////

///////////////////////////Vendor broadcast//////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
class VendorBloc extends Bloc<VendorEvent, VendorState> {
  var logger = Logger();

  VendorBloc() : super(VendorInitial()) {
    on<VendorBroadcastInitialEvent>(vendorBroadcastInitialEvent);
    on<UserPostBroadcastPageNavigateEvent>(userPostBroadcastPageNavigateEvent);
  }

  // EVENT FUNCTIONS for Broadcast page
  // initial event
  FutureOr<void> vendorBroadcastInitialEvent(
      VendorBroadcastInitialEvent event, Emitter<VendorState> emit) async {
    emit(UserPostBroadcastPageOnLoad());
    List<Map<String, dynamic>> jobPostData =
        await VendorCommonFn().fetchDouments('job_posts'); // Fix the typo here
    emit(UserPostBroadcastPageSuccessState(jobData: jobPostData));
  }

  // card press event
  FutureOr<void> userPostBroadcastPageNavigateEvent(
      UserPostBroadcastPageNavigateEvent event,
      Emitter<VendorState> emit) async {
    // Handle the card press event logic here
  }
}
////////////////////////////////////////////////////////////////////////////////

///////////////////////////Vendor proposal action states////////////////////////

////////////////////////////////////////////////////////////////////////////////

// class VendorProposalBloc extends Bloc<VendorEvent, VendorActionState> {
//   VendorProposalBloc() : super(VendorInitialAction()) {
//     on<JobProposalEvent>(jobProposalEvent);
//   }

//   late final CollectionReference<Map<String, dynamic>> _jobPostCollection;

//   // proposal event block
//   FutureOr<void> jobProposalEvent(
//       JobProposalEvent event, Emitter<VendorActionState> emit) async {
//     emit(OnLoad());
//     try {
//       await _jobPostCollection
//           .doc(event.docId)
//           .update({'applicants': event.subData})
//           .then((_) => emit(JobProposalSuccessState(isUpdated: true)))
//           .catchError((onError) => print("Error updating field: $onError"));
//     } catch (e) {
//       print(e);
//       emit(JobProposalFailureState(err: 'Failed to update job proposal.'));
//     }
//   }
// }
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////