part of 'vendor_broadcast_bloc.dart';

enum VendorBroadcastStatus { initial, loading, success, failure }

class VendorBroadcastState extends Equatable {
  const VendorBroadcastState({
    required this.status,
    this.error,
  });

  final VendorBroadcastStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];

  VendorBroadcastState copyWith({
    VendorBroadcastStatus? status,
    String? error,
  }) {
    return VendorBroadcastState(
      status: status ?? this.status,
      error: error,
    );
  }
}