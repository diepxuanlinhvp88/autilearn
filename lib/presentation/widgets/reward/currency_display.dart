import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/reward/reward_bloc.dart';
import '../../../presentation/blocs/reward/reward_event.dart';
import '../../../presentation/blocs/reward/reward_state.dart';
import '../../../data/models/currency_model.dart';

class CurrencyDisplay extends StatelessWidget {
  final String userId;
  final bool showAll;
  final bool isCompact;

  const CurrencyDisplay({
    Key? key,
    required this.userId,
    this.showAll = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardBloc, RewardState>(
      builder: (context, state) {
        if (state is RewardInitial) {
          // Tải tiền tệ khi widget được tạo
          context.read<RewardBloc>().add(LoadUserCurrency(userId));
          return const SizedBox.shrink();
        } else if (state is RewardLoading) {
          return const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        } else if (state is CurrencyLoaded || state is CurrencyUpdated) {
          final CurrencyModel currency;
          if (state is CurrencyLoaded) {
            currency = state.currency;
          } else {
            currency = (state as CurrencyUpdated).currency;
          }

          if (isCompact) {
            return _buildCompactDisplay(currency);
          } else {
            return _buildFullDisplay(currency);
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildCompactDisplay(CurrencyModel currency) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '${currency.stars}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Coins
        Row(
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '${currency.coins}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (showAll) ...[
          const SizedBox(width: 8),
          // Gems
          Row(
            children: [
              const Icon(
                Icons.diamond,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${currency.gems}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFullDisplay(CurrencyModel currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stars
          _buildCurrencyItem(
            icon: Icons.star,
            iconColor: Colors.amber,
            value: currency.stars,
            label: 'Sao',
          ),
          const SizedBox(width: 16),
          // Coins
          _buildCurrencyItem(
            icon: Icons.monetization_on,
            iconColor: Colors.amber,
            value: currency.coins,
            label: 'Xu',
          ),
          if (showAll) ...[
            const SizedBox(width: 16),
            // Gems
            _buildCurrencyItem(
              icon: Icons.diamond,
              iconColor: Colors.blue,
              value: currency.gems,
              label: 'Ngọc',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required IconData icon,
    required Color iconColor,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        if (!isCompact)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}
