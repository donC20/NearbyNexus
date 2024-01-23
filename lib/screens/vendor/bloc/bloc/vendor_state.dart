part of 'vendor_bloc.dart';

@immutable
sealed class VendorState {}

abstract class UserPostBroadcastActionState {}

final class VendorInitial extends VendorState {}

class UserPostBroadcastPageOnLoad extends VendorState {}

class UserPostBroadcastPageErrorState extends VendorState {}

class UserPostBroadcastPageSuccessState extends VendorState {
  final List<Map<String, dynamic>> jobData;
  UserPostBroadcastPageSuccessState({required this.jobData});
}

class UserPostBroadcastPageNavigateFullPage
    extends UserPostBroadcastActionState {}
