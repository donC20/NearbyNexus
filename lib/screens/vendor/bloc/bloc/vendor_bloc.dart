import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'vendor_event.dart';
part 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  VendorBloc() : super(VendorInitial()) {
    on<VendorEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
