import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:smartlaboratory/features/home/presentation/screens/home_main_screen.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/products/presentation/screens/products_list_screen.dart';
import 'package:smartlaboratory/features/settings/presentation/screens/settings_screen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/core/localization/app_locale.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;

  final PageController controller = PageController();

  static const List<Widget> _pages = [
    HomeMainScreen(),
    ProductsListScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final locale = AppLocaleScope.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.text('appName'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              'Laboratoire & stock',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: authState is AuthLoading
                ? null
                : () {
                    context.read<AuthCubit>().logout();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            selected = index;
          });
          if (index == 1) {
            context.read<ProductCubit>().getProducts();
          }
        },
        children: _pages,
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: colors.surface,
        elevation: 10,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        option: AnimatedBarOptions(
          iconStyle: IconStyle.Default,
          barAnimation: BarAnimation.fade,
        ),

        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            title: Text(locale.text('home')),
            selectedColor: colors.primary,
            unSelectedColor: colors.onSurfaceVariant,
          ),

          BottomBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            title: Text(locale.text('products')),
            selectedColor: colors.primary,
            unSelectedColor: colors.onSurfaceVariant,
          ),

          BottomBarItem(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications),
            title: Text(locale.text('alerts')),
            selectedColor: colors.primary,
            unSelectedColor: colors.onSurfaceVariant,
          ),

          BottomBarItem(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            title: Text(locale.text('more')),
            selectedColor: colors.primary,
            unSelectedColor: colors.onSurfaceVariant,
          ),
        ],

        hasNotch: true,

        // IMPORTANT :
        // le notch est au centre
        fabLocation: StylishBarFabLocation.center,

        currentIndex: selected,

        onTap: (index) {
          setState(() {
            selected = index;
          });

          controller.jumpToPage(index);
        },
      ),

      // =========================
      // BOUTON +
      // =========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),

        onPressed: () {
          context.push('/session');
          debugPrint('Ajouter');
        },

        child: const Icon(Icons.add, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
