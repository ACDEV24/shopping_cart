import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shopping_cart/app/models/product.dart';

@immutable
abstract class HomeEvent extends Equatable {
  
}

class FetchProducts extends HomeEvent {

  @override
  List<Object> get props => [];
}

class UpdateProducts extends HomeEvent {

  @override
  List<Object> get props => [];
}

class AddToCar extends HomeEvent {

  final Product product;
  AddToCar(this.product);

  @override
  List<Object> get props => [this.product];
}

class RemoveFromCar extends HomeEvent {

  final Product product;
  RemoveFromCar(this.product);

  @override
  List<Object> get props => [this.product];
}

class ChangeIndex extends HomeEvent {

  final int index;
  ChangeIndex(this.index);

  @override
  List<Object> get props => [this.index];
}

class UploadData extends HomeEvent {

  @override
  List<Object> get props => [];
}

class ClearCart extends HomeEvent {

  @override
  List<Object> get props => [];
}

class Search extends HomeEvent {

  final String query;
  Search(this.query);

  @override
  List<Object> get props => [];
}
