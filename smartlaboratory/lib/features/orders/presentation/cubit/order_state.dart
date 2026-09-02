part of 'order_cubit.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final Order order;
  const OrderDetailLoaded(this.order);
}

class OrderCreated extends OrderState {
  final Order order;
  const OrderCreated(this.order);
}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
}
