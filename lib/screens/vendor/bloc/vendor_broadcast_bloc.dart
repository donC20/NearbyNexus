import 'package:flutter_bloc/flutter_bloc.dart';

part 'vendor_broadcast_events.dart';
part 'vendor_broadcast_state.dart';

class VendorBroadcastBloc extends Bloc<VendorBroadcastEvent, VendorBroadcastState> {
  VendorBroadcastBloc()
      : super(const VendorBroadcastState(
          status: VendorBroadcastStatus.initial,
        )) {
    // TODO: implement event handlers
  }
}