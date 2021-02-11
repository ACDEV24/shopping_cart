import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopping_cart/app/models/product.dart';
import 'package:shopping_cart/app/modules/home/bloc/home_bloc.dart';
import 'package:shopping_cart/app/modules/home/bloc/home_event.dart';
import 'package:shopping_cart/app/utils/methods.dart';
import 'package:shopping_cart/app/utils/screen_size.dart';
import 'package:shopping_cart/app/widgets/custom_circular_progressIndicator.dart';
import 'package:sort_price/sort_price.dart';
import 'package:sweetalert/sweetalert.dart';

class CartPage extends StatelessWidget {

  final HomeBloc bloc;
  final List<Product> products;
  const CartPage(this.bloc, this.products);

  @override
  Widget build(BuildContext context) {

    if(this.products == null) return _NoCarItemsWidget();
    if(this.bloc.state.totalToPay == 0) return _NoCarItemsWidget();

    return Stack(
      children: [
        ListView.builder(
          itemCount: this.products.length,
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 100.0
          ),
          itemBuilder: (_, i) => _CartItemWidget(
            this.products[i],
            bloc
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _ButtonWidget(this.bloc)
        ),
      ],
    );
  }
}

class _NoCarItemsWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(10.0),
    child: FadeIn(
      child: Center(
        child: Text(
          'Actualmente no tienes productos en el carrito',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700
          ),
          textAlign: TextAlign.center
        ),
      ),
    ),
  );
}

class _CartItemWidget extends StatelessWidget {

  final Product product;
  final HomeBloc bloc;
  const _CartItemWidget(this.product, this.bloc);

  @override
  Widget build(BuildContext context) => (this.product.carQuantity == 0) ? Container() : FadeInDown(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 20.0
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ImageWidget(
                bloc: this.bloc,
                product: this.product,
              ),
              SizedBox(width: 15.0),
              _ProductDetail(
                product: this.product,
                bloc: this.bloc,
              )
            ],
          ),
          Text(
            '\$${(this.product.totalPrice == 0) ? '0.0' : sortPrice(this.product.totalPrice, false)}',
            style: TextStyle(
              color: const Color(0xff3ca78b),
              fontSize: 15.0
            )
          )
        ],
      ),
    ),
  );
}

class _ProductDetail extends StatelessWidget {

  final Product product;
  final HomeBloc bloc;

  const _ProductDetail({
    this.product,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100.0,
        child: Text(
          '${this.product.name}',
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700
          ),
        ),
      ),
      SizedBox(height: 15.0),
      Container(
        width: 100.0,
        height: 30.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black
          ),
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              child: SizedBox(
                width: 20.0,
                child: Icon(
                  Icons.remove,
                  size: 20.0,
                  color: Colors.black
                ),
              ),
              onTap: () {

                int quantity = 0;

                if(this.product.carQuantity > 0) quantity = this.product.carQuantity - 1;

                final Product product = this.product.copyWith(
                  carQuantity: quantity
                );

                this.bloc.add(RemoveFromCar(product));
              }
            ),
            Text(
              '${this.product.carQuantity}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0
              ),
            ),
            InkWell(
              child: SizedBox(
                width: 20.0,
                child: Icon(
                  Icons.add,
                  size: 20.0,
                  color: Colors.black
                ),
              ),
              onTap: () {
                
                final Product product = this.product.copyWith(
                  carQuantity: this.product.carQuantity + 1
                );

                this.bloc.add(AddToCar(product));
              }
            ),
          ],
        ),
      ),
    ],
  );
}

class _ImageWidget extends StatelessWidget {

  final HomeBloc bloc;
  final Product product;

  const _ImageWidget({
    this.bloc,
    this.product,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: getColor(this.product.picture),
    builder: (_, snapshot) => Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: snapshot.data,
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: CachedNetworkImage(
        imageUrl: this.product.picture,
        placeholder: (_, url) => Image(
          image: AssetImage('assets/loading.gif'), 
          height: 150.0,
          width: 150.0,
          fit: BoxFit.cover
        ),
        errorWidget: (_, __, ___) => Icon(Icons.error),
        height: 100.0,
        width: 100.0
      ),
    )
  );
}

class _ButtonWidget extends StatelessWidget {

  final HomeBloc bloc;
  const _ButtonWidget(this.bloc);

  @override
  Widget build(BuildContext context) => MaterialButton(
    color: this.bloc.app.primaryColor,
    padding: EdgeInsets.symmetric(
      horizontal: ScreenSize.width * 0.35,
      vertical: 10.0
    ),
    disabledColor: Colors.grey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0)
    ),
    child: (this.bloc.state.isLoading && this.bloc.state is UploadData) ? CustomCircularProgressIndicator(
      size: 20.0,
    ) : Text(
      'Comprar',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0
      ),
    ),
    onPressed: (this.bloc.state.cart.length == 0) ? null : () {
      SweetAlert.show(
        context,
        title: '\n¿Desea realizar esta compra?',
        subtitle: '',
        style: SweetAlertStyle.confirm,
        showCancelButton: true,
        cancelButtonText: 'Cancelar',
        confirmButtonText: 'Confirmar',
        onPress: (bool isConfirm) {
          
        if (isConfirm) {
          this.bloc.add(UploadData());
          SweetAlert.show(
            context,
            style: SweetAlertStyle.success,
            title: 'Success'
          );
          return false;
        }
        
        return true;
      });
    },
  );
}
