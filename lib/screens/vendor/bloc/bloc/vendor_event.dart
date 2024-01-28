part of 'vendor_bloc.dart';

@immutable
sealed class VendorEvent {}

class VendorBroadcastInitialEvent extends VendorEvent {}

class UserPostBroadcastPageNavigateEvent extends VendorEvent {}

class JobProposalEvent extends VendorEvent {
  final String docId;
  final Map<String, dynamic> subData;

  JobProposalEvent({required this.docId, required this.subData});
}
