import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../../../../application/injector.dart';
import '../../domain/entities/home_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<HomeBloc>(
      create: (BuildContext context) => Injector.get<HomeBloc>()..add(const HomeEvent.initialized()),
      child: const HomeView(),
    );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.failure != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Error: ${state.failure!.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const HomeEvent.initialized());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Text('No items available'),
            );
          }

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (BuildContext context, int index) {
              final HomeEntity item = state.items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                leading: CircleAvatar(
                  child: Text(item.id),
                ),
              );
            },
          );
        },
      ),
    );
}

