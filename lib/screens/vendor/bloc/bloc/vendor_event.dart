part of 'vendor_bloc.dart';

@immutable
sealed class VendorEvent {}

class VendorBroadcastInitialEvent extends VendorEvent {}


class UserPostBroadcastPageNavigateEvent extends VendorEvent {}
