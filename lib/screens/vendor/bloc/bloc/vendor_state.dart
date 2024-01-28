part of 'vendor_bloc.dart';

@immutable
sealed class VendorState {}

abstract class VendorActionState {}

final class VendorInitial extends VendorState {}

final class VendorInitialAction extends VendorActionState {}

class UserPostBroadcastPageOnLoad extends VendorState {}

class UserPostBroadcastPageErrorState extends VendorState {}

class UserPostBroadcastPageSuccessState extends VendorState {
  final List<Map<String, dynamic>> jobData;
  UserPostBroadcastPageSuccessState({required this.jobData});
}

class UserPostBroadcastPageNavigateFullPage extends VendorActionState {}

//------------------------------------------------------------------
// job proposal page
class OnLoad extends VendorActionState {}

class JobProposalSuccessState extends VendorActionState {
  final bool isUpdated;
  JobProposalSuccessState({required this.isUpdated});
}

class JobProposalFailureState extends VendorActionState {
  final String err;
  JobProposalFailureState({required this.err});
}
// -----------------------------------------------------------------