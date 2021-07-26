import 'package:cards/shader.dart';
import 'package:cards/grid1.dart';
import 'package:cards/grid2.dart';
import 'package:cards/grid3.dart';
import 'package:cards/grid4.dart';
import 'package:cards/hero.dart';
import 'package:cards/hero1.dart';
import 'package:cards/hero2.dart';
import 'package:cards/hero3.dart';
import 'package:cards/hero4.dart';
import 'package:cards/hero5.dart';
import 'package:cards/heart_shaker.dart';
import 'package:cards/mars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    routes: {
      "/": (context) => Home(),
      "/heart_shaker": (context) => HeartShaker(),
      "/mars": (context) => Mars(),
      "/grid1": (context) => Grid1(),
      "/grid2": (context) => Grid2(),
      "/grid3": (context) => Grid3(),
      "/grid4": (context) => Grid4(),
      "/shader": (context) => Shader(),
      "/hero": (context) => Hero1(),
      "/hero1": (context) => Hero2Page(),
      "/hero2": (context) => Hero3Page(),
      "/hero3": (context) => Hero4Page(),
      "/hero4": (context) => Hero5Page(),
      "/hero5": (context) => Hero6Page(),
    },
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Title("cards"),
            // https://www.woolha.com/tutorials/flutter-card-widget-example
            Button("Heart Shaker", route: "/heart_shaker"),
            // https://github.com/sergiandreplace/flutter_planets_tutorial
            Button("Mars", route: "/mars"),
            Title("grids"),
            // https://www.kindacode.com/article/flutter-gridview-builder-example/
            // nesse utiliza grid view builder que utiliza delegate
            // SliverGridDelegateWithMaxCrossAxisExtent para limitar o tamanho dos cards
            // a quantidade de colunas não é fixa, ela muda respeitando o tamanho maximo dos cards
            Button("Grid1", route: "/grid1"),
            // nesse utiliza grid view builder que utiliza delegate
            // SliverGridDelegateWithFixedCrossAxisCount para limitar a quantidade de colunas
            // o tamanho do cards é de acordo com o tamanho da tela
            Button("Grid2", route: "/grid2"),
            // nesse utiliza grid view count que fixa diretamente a quantidade de coluna
            // os cards precisam ser colocados diretamente no children
            // o tamanho do cards é de acordo com o tamanho da tela
            Button("Grid3", route: "/grid3"),
            Title("shader"),
            // tentativa de uso de mascaras nos cards da grid
            // o efeito é transformar a picture em uma imagem parcialemente dissipada
            // para isso utiliza-se uma imagem preto e branco com transparencia
            // e é mesclado nas imagens
            // NAO FUNCIONA DIREITO, para celular do android funciona, mas quando vai pra
            // telas maiores ou web a imagem fica distorcida
            Button("Shader", route: "/shader"),

            Title("hero"),
            Button("Hero", route: "/hero"),
            // https://flutter.dev/docs/development/ui/animations/hero-animations
            Button("Hero animação grande -> pequeno", route: "/hero1"),
            Button("Hero animação grande -> pequeno", route: "/hero2"),
            Button("Hero animação p/ centro completo", route: "/hero3"),
            Button("Hero animação p/ centro simplificado", route: "/hero4"),
            Button("Hero", route: "/hero5"),
          ],
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class Button extends StatelessWidget {
  const Button(this.title, {required this.route, Key? key}) : super(key: key);

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(title),
      ),
    );
  }
}
