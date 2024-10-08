import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../size_config.dart';
import '../models/cart_item.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

Cart cart;

class CartItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    cart = Provider.of<Cart>(context);

    return Scaffold(
        backgroundColor: cart.isEmpty
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).accentColor,
        body: SafeArea(
          child: cart.isEmpty ? EmptyCartWarning() : CartScreen(),
        ),
        bottomNavigationBar: cart.isEmpty ? null : Footer());
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(),
        ItemsList(),
      ],
    );
  }
}

class ItemsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black54,
      color: const Color(0xFFc447fc),
      child: Container(
        height: SizeConfig.getHeightPercentage(63),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: cart.distinctItemsCount,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.all(3.0),
            child: ItemTile(cart.items.elementAt(index)),
          ),
        ),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final CartItem item;
  ItemTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10),
      tileColor: const Color(0xFFca6ff2),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(item.product.imageUrl),
      ),
      title: Text(
        item.product.title,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: SizeConfig.textScaleFactor * 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor: R\$${item.product.price.toStringAsFixed(2).replaceAll(".", ",")}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Quantidade: ${item.quantity}',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      trailing: Column(
        children: [
          Flexible(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => cart.increaseQuantity(item),
            ),
          ),
          Flexible(
            child: IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => cart.decreaseQuantity(item),
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context, listen: false);
    const textStyle = TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.white,
      shadows: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 4,
        ),
      ],
    );
    return Card(
      elevation: 15,
      color: const Color(0xFFc447fc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: SizeConfig.getHeightPercentage(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      'Total de itens: ${cart.totalItemsCount}',
                      style: textStyle,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Valor total: R\$${cart.totalValue.toStringAsFixed(2).replaceAll(".", ",")}',
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
            PayButton(orders: orders),
          ],
        ),
      ),
    );
  }
}

class PayButton extends StatefulWidget {
  const PayButton({@required this.orders});

  final Orders orders;

  @override
  _PayButtonState createState() => _PayButtonState();
}

class _PayButtonState extends State<PayButton> {
  bool isProcessingPayment = false;

  void processPayment() async {
    toggleProcessingStatus();

    try {
      await widget.orders.createOrder(cart.items);

      cart.clear();
    } catch (e) {
      toggleProcessingStatus();

      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e, textAlign: TextAlign.center),
        ),
      );
    }
  }

  void toggleProcessingStatus() {
    setState(() => isProcessingPayment = !isProcessingPayment);
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.pinkAccent,
      child: Text(
        isProcessingPayment ? 'PROCESSANDO...' : 'PAGAR',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
        ),
      ),
      onPressed: isProcessingPayment ? null : processPayment,
    );
  }
}

class EmptyCartWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/bag.json'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Quando você adicionar roupas na sua sacolinha, elas irão aparecer aqui!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: SizeConfig.getHeightPercentage(23),
              width: double.infinity,
              color: Theme.of(context).accentColor,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: SizeConfig.getHeightPercentage(25),
            child: Lottie.asset('assets/animations/woman-with-bags.json'),
          ),
        ),
      ],
    );
  }
}
