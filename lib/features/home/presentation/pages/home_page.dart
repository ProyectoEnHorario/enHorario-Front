import 'package:enhorario/core/constants/app_strings.dart';
import 'package:enhorario/core/widgets/section_card.dart';
import 'package:enhorario/features/home/domain/entities/wait_point.dart';
import 'package:enhorario/features/home/domain/repositories/wait_point_repository.dart';
import 'package:enhorario/features/home/presentation/widgets/wait_point_tile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
  });

  final WaitPointRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<WaitPoint>> _waitPointsFuture;

  @override
  void initState() {
    super.initState();
    _waitPointsFuture = widget.repository.getTodayWaitPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.homeTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.homeSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<WaitPoint>>(
                future: _waitPointsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'No fue posible cargar la información.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final points = snapshot.data ?? <WaitPoint>[];

                  if (points.isEmpty) {
                    return const Center(
                      child: Text('No hay puntos de espera disponibles.'),
                    );
                  }

                  return SectionCard(
                    child: ListView.separated(
                      itemBuilder: (context, index) =>
                          WaitPointTile(point: points[index]),
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemCount: points.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
