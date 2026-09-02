import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit({required this._orderRepository}) : super(OrderInitial());

  Future<void> getOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrders(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> getOrder(int id) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getOrder(id);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.createOrder(
        supplierId: supplierId,
        items: items,
        notes: notes,
        expectedDeliveryDate: expectedDeliveryDate,
      );
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> updateOrder(
    int id, {
    String? status,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.updateOrder(
        id,
        status: status,
        notes: notes,
        expectedDeliveryDate: expectedDeliveryDate,
      );
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> cancelOrder(int id) async {
    emit(OrderLoading());
    try {
      await _orderRepository.cancelOrder(id);
      emit(OrderCancelled());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
