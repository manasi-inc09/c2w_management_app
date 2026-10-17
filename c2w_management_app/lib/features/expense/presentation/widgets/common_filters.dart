import 'package:c2w_management_app/features/enquiry/presentation/widgets/filters.dart';
import 'package:flutter/material.dart';

class CommonFilters {
  PreferredSize getCommonFilter(
    BuildContext context,Map<String,String> appliedFilters,List<String> filterList){
  //   List<String> filterList, {
  //   Map<String, String?>? = const [],
  // }) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),

      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),

        child: Row(
          children: [
            const SizedBox(width: 20),

            Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await showFilterSheet(
                      context,
                      initialFilters: appliedFilters,
                    );

                    // if (result != null) {
                    //   onFilterChanged?.call(result);
                    // }
                  },
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),

                Positioned(
                  right: 0,

                  child: Container(
                    height: 18,
                    width: 18,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),

                    child: Center(
                      child: Text(
                        "${appliedFilters.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 40,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: filterList.length,

                  itemBuilder: (context, index) {
                    return Container(
                      height: 40,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),

                      margin: const EdgeInsets.only(right: 10),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),

                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(
                            255, 255, 255, 0.1,
                          ),
                        ),

                        color: const Color.fromRGBO(
                          255, 255, 255, 0.06,
                        ),
                      ),

                      child: Center(
                        child: Text(
                          filterList[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}