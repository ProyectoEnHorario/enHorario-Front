import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/establishments/presentation/bloc/wait_time_rating_cubit.dart';

class CalificacionPrecisionWidget extends StatefulWidget {
  final String establishmentId;

  const CalificacionPrecisionWidget({
    super.key,
    required this.establishmentId,
  });

  @override
  State<CalificacionPrecisionWidget> createState() => _CalificacionPrecisionWidgetState();
}

class _CalificacionPrecisionWidgetState extends State<CalificacionPrecisionWidget> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaitTimeRatingCubit, WaitTimeRatingState>(
      builder: (context, state) {
        if (state.isSuccess || context.read<WaitTimeRatingCubit>().hasAlreadyRated(widget.establishmentId)) {
          return _buildSuccessCard();
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '¿Qué tan preciso fue este tiempo?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (state.isLoading)
                  const CircularProgressIndicator()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final ratingValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          ratingValue <= _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() => _selectedRating = ratingValue);
                          context.read<WaitTimeRatingCubit>().sendRating(
                                widget.establishmentId,
                                ratingValue,
                              );
                        },
                      );
                    }),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Text(
              '¡Gracias por tu calificación!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
