part of 'vendor_bloc.dart';

@immutable
sealed class VendorState {}

abstract class UserPostBroadcastActionState {}

final class VendorInitial extends VendorState {}

class UserPostBroadcastPageErrorState extends VendorState {}

class UserPostBroadcastPageSuccessState extends VendorState {}

class UserPostBroadcastPageNavigateFullPage extends UserPostBroadcastActionState {}
