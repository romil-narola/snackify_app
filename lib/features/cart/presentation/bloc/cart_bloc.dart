import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final SnackModel snack;
  final int quantity;
  const AddToCart(this.snack, {this.quantity = 1});
  @override
  List<Object?> get props => [snack, quantity];
}

class RemoveFromCart extends CartEvent {
  final String snackId;
  const RemoveFromCart(this.snackId);
  @override
  List<Object?> get props => [snackId];
}

class UpdateQuantity extends CartEvent {
  final String snackId;
  final int quantity;
  const UpdateQuantity(this.snackId, this.quantity);
  @override
  List<Object?> get props => [snackId, quantity];
}

class ClearCart extends CartEvent {}

// --- States ---
class CartState extends Equatable {
  final List<CartItem> items;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;

  const CartState({
    this.items = const [],
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.tax = 0.0,
    this.finalAmount = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
    );
  }

  @override
  List<Object?> get props => [items, totalAmount, discount, tax, finalAmount];
}

// --- BLoC ---
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere(
      (item) => item.snack.id == event.snack.id,
    );

    if (index != -1) {
      final oldItem = updatedItems[index];
      updatedItems[index] = oldItem.copyWith(
        quantity: oldItem.quantity + event.quantity,
      );
    } else {
      updatedItems.add(CartItem(snack: event.snack, quantity: event.quantity));
    }

    emit(_calculateAmounts(updatedItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.snack.id == event.snackId);
    emit(_calculateAmounts(updatedItems));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.snackId));
      return;
    }

    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere(
      (item) => item.snack.id == event.snackId,
    );

    if (index != -1) {
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: event.quantity,
      );
    }

    emit(_calculateAmounts(updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  CartState _calculateAmounts(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      total += item.totalPrice;
    }

    // Apply office subsidy / discount (e.g. 10% off for orders above $10)
    double discount = total > 10.0 ? total * 0.1 : 0.0;
    // Office tax / handling fee (5%)
    double tax = total * 0.05;
    double finalAmt = total - discount + tax;

    return CartState(
      items: items,
      totalAmount: total,
      discount: discount,
      tax: tax,
      finalAmount: finalAmt,
    );
  }
}
