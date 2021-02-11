import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shopping_cart/app/bloc/app_bloc.dart';
import 'package:shopping_cart/app/models/product.dart';
import 'package:shopping_cart/app/modules/home/bloc/home_event.dart';
import 'package:shopping_cart/app/shared/bloc_builder.dart';
import 'package:shopping_cart/app/utils/dialogs.dart';
import 'package:shopping_cart/app/utils/methods.dart';
import 'package:shopping_cart/app/utils/screen_size.dart';
import 'package:shopping_cart/app/widgets/custom_circular_progressIndicator.dart';
import 'package:sort_price/sort_price.dart';

import 'bloc/home_bloc.dart';
import 'bloc/home_state.dart';
import 'pages/cart_page.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomeBloc get bloc => Modular.get<HomeBloc>();

  @override
  void initState() { 
    this.bloc.add(FetchProducts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    bloc: this.bloc,
    builder: (_, state) => Scaffold(
      appBar: AppBar(
        title: Text(
          'Home'
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: (this.bloc.state.index != 0) ? null : _BottomAppbar(this.bloc),
        leading: IconButton(
          icon: Icon(
            (state.index == 0) ? Icons.shopping_cart : Icons.arrow_back,
            color: Colors.white,
          ),
          splashRadius: 20.0,
          onPressed: () {

            if(state.index > 0) {
              this.bloc.add(ChangeIndex(state.index - 1));
            }

            else this.bloc.add(ChangeIndex(state.index + 1));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: (state.index == 1) ? 
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () {
                  if(state.cart == null || state.cart.isEmpty) {
                    return showSnack('No tienes productos seleccionados');
                  }
                  this.bloc.add(ClearCart());
                }
              ) : Text(
                '\$${(state.totalToPay == 0) ? '0.0' : sortPrice(state.totalToPay, false)}',
                style: TextStyle(
                  fontSize: 16.0
                )
              ),
            ),
          )
        ],
      ),
      body: Builder(
        builder: (context) {

          if(state is HomeState) {

            if(state.products == null) {
              return _LoadingWidget(this.bloc.app);
            }

            if(state.index == 0) {
              return _ProductsWidget(state.filteredProducts, this.bloc);
            } else {
              return CartPage(this.bloc, state.cart);
            }

          } else if(state is ErrorFetchingProducts) return Center(
            child: Text('${state.error}')
          );
          else {
            return Container();
          }
        },
      ),
    )
  );
}

class _LoadingWidget extends StatelessWidget {

  final AppBloc app;
  const _LoadingWidget(this.app);

  @override
  Widget build(BuildContext context) => Center(
    child: CustomCircularProgressIndicator(
      color: this.app.primaryColor,
    ),
  );
}

class _ProductsWidget extends StatelessWidget {

  final List<Product> products;
  final HomeBloc bloc;
  const _ProductsWidget(this.products, this.bloc);

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async => this.bloc.add(FetchProducts()),
    child: ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: this.products.length,
      itemBuilder: (_, i) => _ItemWidget(this.products[i], this.bloc),
    ),
  );
}


class _ItemWidget extends StatelessWidget {

  final Product product;
  final HomeBloc bloc;
  const _ItemWidget(this.product, this.bloc);

  @override
  FutureBuilder<Color> build(BuildContext context) => FutureBuilder<Color>(
    future: getColor(this.product.picture),
    builder: (_, snapshot) => FadeIn(
      duration: const Duration(milliseconds: 600),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            topLeft: Radius.circular(15.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 0.0),
              blurRadius: 15.0,
              spreadRadius: 1.5
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MiddleItem(
              product: this.product,
              color: snapshot.data,
              bloc: this.bloc
            ),
            _AddToCarWidget(this.product, this.bloc)
          ],
        ),
      ),
    ),
  );
}

class _MiddleItem extends StatelessWidget {

  final Product product;
  final Color color;
  final HomeBloc bloc;
  const _MiddleItem({this.product, this.color, this.bloc});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ImageWidget(
        color: this.color,
        product: product
      ),
      Container(
        width: 125.0,
        padding: const EdgeInsets.only(
          left: 10.0,
          top: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${this.product.name}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.0
              ),
            ),
            SizedBox(height: 38.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Precio: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0
                    )
                  ),
                  TextSpan(
                    text: '\$${sortPrice(this.product.price, false)}',
                    style: TextStyle(
                      color: const Color(0xff3ca78b),
                      fontSize: 15.0
                    )
                  ),
                ]
              ),
            ),
            SizedBox(
              height: 38.0
            ),
            Builder(
              builder: (_) {

                if(this.product.totalPrice == 0) return FadeOut();

                return FadeIn(
                  duration: const Duration(milliseconds: 200),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Total: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0
                          )
                        ),
                        TextSpan(
                          text: '\$${sortPrice(this.product.totalPrice, false)}',
                          style: TextStyle(
                            color: const Color(0xff3ca78b),
                            fontSize: 16.0
                          )
                        ),
                      ]
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    ],
  );
}

class _ImageWidget extends StatelessWidget {

  final Color color;
  final Product product;

  const _ImageWidget({
    this.color,
    this.product,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      color: this.color,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15.0),
        topLeft: Radius.circular(15.0),
      )
    ),
    child: CachedNetworkImage(
      imageUrl: this.product.picture,
      placeholder: (_, url) => Image(
        image: AssetImage('assets/loading.gif'), 
        height: 150.0,
        fit: BoxFit.cover
      ),
      fit: BoxFit.fill,
      errorWidget: (_, __, ___) => Icon(Icons.error),
      height: 150.0,
      width: ScreenSize.width * 0.26
    ),
  );
}

class _AddToCarWidget extends StatelessWidget {

  final Product product;
  final HomeBloc bloc;

  const _AddToCarWidget(this.product, this.bloc);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      right: 8.0,
      bottom: 8.0
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(height: 5.0),
        InkWell(
          splashColor: Colors.grey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                )
              ],
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.add,
              size: 30.0,
              color: const Color(0xff3ca78b)
            ),
          ),
          onTap: () {
            final Product product = this.product.copyWith(
              carQuantity: this.product.carQuantity + 1
            );
            this.bloc.add(AddToCar(product));
          }
        ),
        SizedBox(height: 20.0),
        Container(
          height: 45.0,
          width: 25.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
              )
            ]
          ),
          child: Center(
            child: Text(
              '${this.product.carQuantity}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                )
              ],
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.remove,
              size: 30.0,
              color: Colors.red
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
      ],
    ),
  );
}


class _BottomAppbar extends StatelessWidget with PreferredSizeWidget {

  final HomeBloc bloc;
  const _BottomAppbar(this.bloc);

  @override
  Widget build(BuildContext context) => PreferredSize(
    child: Container(
      padding: const EdgeInsets.all(
        10.0
      ),
      child: Card(
        child: Container(
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Buscar producto',
              icon: IconButton(
                icon: Icon(
                  Icons.search
                ),
                onPressed: () {}
              ),
            ),
            onChanged: (value) => this.bloc.add(Search(value)),
          ),
        ),
      ),
    ),
    preferredSize: Size.fromHeight(80.0),
  );

  @override  
  Size get preferredSize => Size.fromHeight(80.0);
}
