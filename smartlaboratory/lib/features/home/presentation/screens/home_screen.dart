import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:smartlaboratory/features/home/presentation/screens/home_main_screen.dart';
import 'package:smartlaboratory/features/laboratory/presentation/screens/new_analysis_session_screen.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.text('appName')),
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
        },
        children: _pages,
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
          iconStyle: IconStyle.Default,
          barAnimation: BarAnimation.fade,
        ),

        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            title: Text(locale.text('home')),
            selectedColor: const Color.fromARGB(255, 54, 214, 126),
            unSelectedColor: Colors.grey,
          ),

          BottomBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            title: Text(locale.text('products')),
            selectedColor: const Color.fromARGB(255, 54, 214, 126),
            unSelectedColor: Colors.grey,
          ),

          BottomBarItem(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications),
            title: Text(locale.text('alerts')),
            selectedColor: const Color.fromARGB(255, 54, 214, 126),
            unSelectedColor: Colors.grey,
          ),

          BottomBarItem(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            title: Text(locale.text('more')),
            selectedColor: const Color.fromARGB(255, 54, 214, 126),
            unSelectedColor: Colors.grey,
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
        backgroundColor: const Color.fromARGB(255, 54, 214, 126),
        elevation: 6,
        shape: const CircleBorder(),

        onPressed: () {
          // Action du bouton +
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewAnalysisSessionScreen(),
            ),
          );
          debugPrint('Ajouter');
        },

        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
