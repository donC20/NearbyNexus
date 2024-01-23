import 'dart:async';

import 'package:bloc/bloc.dart';
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
      VendorBroadcastInitialEvent event, Emitter<VendorState> emit) {
    emit(UserPostBroadcastPageOnLoad());
  }

  // card press event
  FutureOr<void> userPostBroadcastPageNavigateEvent(
      UserPostBroadcastPageNavigateEvent event, Emitter<VendorState> emit) {}
}
