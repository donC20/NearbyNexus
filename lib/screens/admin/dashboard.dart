import 'package:flutter/material.dart';
import 'package:NearbyNexus/screens/admin/component/appBarActionItems.dart';
import 'package:NearbyNexus/screens/admin/component/barChart.dart';
import 'package:NearbyNexus/screens/admin/component/header.dart';
import 'package:NearbyNexus/screens/admin/component/historyTable.dart';
import 'package:NearbyNexus/screens/admin/component/infoCard.dart';
import 'package:NearbyNexus/screens/admin/component/paymentDetailList.dart';
import 'package:NearbyNexus/screens/admin/component/sideMenu.dart';
import 'package:NearbyNexus/screens/admin/config/responsive.dart';
import 'package:NearbyNexus/screens/admin/config/size_config.dart';
import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:NearbyNexus/screens/admin/style/style.dart';

class Dashboard extends StatelessWidget {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _drawerKey,
      drawer: const SizedBox(width: 100, child: SideMenu()),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              elevation: 0,
              backgroundColor: AppColors.white,
              leading: IconButton(
                  onPressed: () {
                    _drawerKey.currentState!.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: AppColors.black)),
              actions: const [
                AppBarActionItems(),
              ],
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
                flex: 10,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Header(),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 4,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth,
                          child: const Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              InfoCard(
                                  icon: 'assets/images/vector/credit-card.svg',
                                  label: 'Transafer via \nCard number',
                                  amount: '\$1200'),
                              InfoCard(
                                  icon: 'assets/images/vector/transfer.svg',
                                  label: 'Transafer via \nOnline Banks',
                                  amount: '\$150'),
                              InfoCard(
                                  icon: 'assets/images/vector/bank.svg',
                                  label: 'Transafer \nSame Bank',
                                  amount: '\$1500'),
                              InfoCard(
                                  icon: 'assets/images/vector/invoice.svg',
                                  label: 'Transafer to \nOther Bank',
                                  amount: '\$1500'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 4,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PrimaryText(
                                  text: 'Balance',
                                  size: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondary,
                                ),
                                PrimaryText(
                                    text: '\$1500',
                                    size: 30,
                                    fontWeight: FontWeight.w800),
                              ],
                            ),
                            PrimaryText(
                              text: 'Past 30 DAYS',
                              size: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 3,
                        ),
                        // ignore: prefer_const_constructors
                        SizedBox(
                          height: 180,
                          child: const BarChartCopmponent(),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 5,
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrimaryText(
                                text: 'History',
                                size: 30,
                                fontWeight: FontWeight.w800),
                            PrimaryText(
                              text: 'Transaction of lat 6 month',
                              size: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 3,
                        ),
                        const HistoryTable(),
                        if (!Responsive.isDesktop(context))
                          const PaymentDetailList()
                      ],
                    ),
                  ),
                )),
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 4,
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: SizeConfig.screenHeight,
                    decoration:
                        const BoxDecoration(color: AppColors.secondaryBg),
                    child: const SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                      child: Column(
                        children: [
                          AppBarActionItems(),
                          PaymentDetailList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
