import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/app/router/app_router.dart';

class RaportaApp extends StatelessWidget {
  const RaportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Raporta',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
