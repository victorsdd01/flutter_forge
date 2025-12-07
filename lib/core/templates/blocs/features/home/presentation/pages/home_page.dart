import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:{{project_name}}/features/home/presentation/blocs/home_bloc/home_event.dart';
import 'package:{{project_name}}/application/injector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injector.get<HomeBloc>()..add(const HomeEvent.initialized()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.failure != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to your Flutter app!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  'This project uses BLoC with Clean Architecture',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

