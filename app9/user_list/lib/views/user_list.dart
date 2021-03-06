import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_list/components/user_tile.dart';
import 'package:user_list/provider/users.dart';
import 'package:user_list/routes/app_routes.dart';

class UserList extends StatelessWidget {
  final String title;

  UserList({required this.title});

  @override
  Widget build(BuildContext context) {
    // recupera o acesso do provider relacionado ao Users declarado no MultiProvider
    final Users users = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.USER_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      // este componente serve para criar listas on demand, sem a necessidade
      // de carregar todos os itens de uma vez
      body: ListView.builder(
        itemCount: users.count,
        itemBuilder: (context, i) => UserTile(users.byIndex(i)),
      ),
    );
  }
}
