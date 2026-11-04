import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ControleConsumoApp());
}

class AppColors {
  static const Color verdeEletrico = Color(0xFF00D084); // Principal: ações, botões, indicadores positivos
  static const Color verdeProfundo = Color(0xFF0B3D2E); // Secundária: cards destacados, superfícies
  static const Color pretoGrafite = Color(0xFF0E0F11);  // Fundo principal premium
  static const Color cinzaSecundario = Color(0xFF6B7280); // Legendas, datas, descrições
  static const Color brancoLeitura = Color(0xFFFFFFFF); // Títulos, números e textos principais
  static const Color superficieCard = Color(0xFF16191D); // Superfície neutra de apoio para listas
}

class ControleConsumoApp extends StatelessWidget {
  const ControleConsumoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Consumo de Veículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.pretoGrafite,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.verdeEletrico,
          onPrimary: AppColors.pretoGrafite,
          secondary: AppColors.verdeProfundo,
          onSecondary: AppColors.brancoLeitura,
          surface: AppColors.superficieCard,
          onSurface: AppColors.brancoLeitura,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.pretoGrafite,
          foregroundColor: AppColors.brancoLeitura,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.brancoLeitura,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.verdeEletrico,
          unselectedLabelColor: AppColors.cinzaSecundario,
          indicatorColor: AppColors.verdeEletrico,
          dividerColor: AppColors.verdeProfundo,
        ),
        cardTheme: CardThemeData(
          color: AppColors.superficieCard,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.verdeProfundo, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.verdeEletrico,
            foregroundColor: AppColors.pretoGrafite,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brancoLeitura,
            side: const BorderSide(color: AppColors.verdeProfundo, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.pretoGrafite,
          labelStyle: const TextStyle(color: AppColors.cinzaSecundario),
          helperStyle: const TextStyle(color: AppColors.cinzaSecundario),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.verdeProfundo),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.verdeEletrico, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.pretoGrafite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.verdeProfundo, width: 1.5),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.brancoLeitura,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.brancoLeitura,
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.verdeProfundo,
          thickness: 1,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}