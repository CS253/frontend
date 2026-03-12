import 'package:flutter/material.dart';
import 'dart:ui';

class CreateTripDialog extends StatefulWidget {
  const CreateTripDialog({super.key});

  @override
  State<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pop(context); // Close after 3rd step
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context); // Close if on 1st step
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 650, // Fixed height for modal flow
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _previousStep,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF5A7184)),
                          ),
                        ),
                      Text(
                        _currentStep == 0 ? 'New Trip' : _currentStep == 1 ? 'Add Members' : 'Review Trip',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24, color: Color(0xFF5A7184)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5EAF4)),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? const Color(0xFF6BB5E5) : const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swiping
                children: [
                   _buildStep1Details(),
                   _buildStep2Members(),
                   _buildStep3Review(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Trip Name'),
          _buildTextField(),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Destination', icon: Icons.location_on_outlined),
          _buildTextField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('From', icon: Icons.calendar_today_outlined),
                    _buildTextField(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('To'),
                    _buildTextField(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Trip Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
               _buildTypeChip('Beach', '🏖️', true),
               _buildTypeChip('Mountain', '⛰️', false),
               _buildTypeChip('City', '🏙️', false),
               _buildTypeChip('Nature', '🌿', false),
               _buildTypeChip('Island', '🏝️', false),
               _buildTypeChip('Other', '🌍', false),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Cover Photo', icon: Icons.camera_alt_outlined),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFCFC),
              border: Border.all(color: const Color(0xFFEBEBEB), style: BorderStyle.none),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                 Positioned.fill(
                   child: CustomPaint(
                     painter: DashedRectPainter(color: const Color(0xFFE0E0E0)),
                   ),
                 ),
                 Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                       Icon(Icons.upload_outlined, color: Color(0xFF828282)),
                       SizedBox(height: 8),
                       Text(
                         'Tap to upload',
                         style: TextStyle(
                           fontFamily: 'Inter',
                           fontSize: 12,
                           color: Color(0xFF828282),
                         ),
                       ),
                    ],
                  ),
                 ),
              ]
            )
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton('Continue', _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep2Members() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Name'),
          _buildTextField(),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Phone Number'),
          _buildTextField(),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Or Add from Contacts'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_add_outlined, color: Color(0xFF6BB5E5)),
                SizedBox(width: 8),
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                const Icon(Icons.people_outline, size: 48, color: Color(0xFFB0B0B0)),
                const SizedBox(height: 16),
                const Text(
                  'No members added yet',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF828282),
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You can always add them later',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48), // Padding before button
          _buildPrimaryButton('Continue', _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Card
          Container(
             clipBehavior: Clip.hardEdge,
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: const Color(0xFFF3F3F3)),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                   height: 120,
                   width: double.infinity,
                   color: const Color(0xFFFAF1ED),
                   child: const Center(
                     child: Text('🏖️', style: TextStyle(fontSize: 32)),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text(
                         'Kashish\'s Wedding',
                         style: TextStyle(
                           fontFamily: 'Inter',
                           fontSize: 16,
                           fontWeight: FontWeight.w700,
                           color: Color(0xFF282828),
                         ),
                       ),
                       const SizedBox(height: 8),
                       Row(
                         children: const [
                           Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF828282)),
                           SizedBox(width: 4),
                           Text(
                             'Lyaari',
                             style: TextStyle(
                               fontFamily: 'Inter',
                               fontSize: 12,
                               color: Color(0xFF828282),
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Row(
                         children: [
                           Row(
                             children: const [
                               Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF828282)),
                               SizedBox(width: 4),
                               Text(
                                 'Dec 31 - Jan 22',
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   fontSize: 12,
                                   color: Color(0xFF828282),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(width: 16),
                           Row(
                             children: const [
                               Icon(Icons.people_outline, size: 14, color: Color(0xFF828282)),
                               SizedBox(width: 4),
                               Text(
                                 '10 members',
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   fontSize: 12,
                                   color: Color(0xFF828282),
                                 ),
                               ),
                             ],
                           ),
                         ],
                       )
                     ],
                   ),
                 )
               ],
             ),
          ),
          const SizedBox(height: 24),
          _buildChecklistItem('Trip details'),
          const SizedBox(height: 8),
          _buildChecklistItem('Dates set'),
          const SizedBox(height: 8),
          _buildChecklistItem('Trip type selected'),
          const SizedBox(height: 8),
          _buildChecklistItem('Members invited'),
          
          const SizedBox(height: 32),
          _buildPrimaryButton('Create Trip', _nextStep),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF6F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
           const Icon(Icons.check_circle, color: Color(0xFF20B95B), size: 20),
           const SizedBox(width: 12),
           Text(
             title,
             style: const TextStyle(
               fontFamily: 'Inter',
               fontSize: 13,
               color: Color(0xFF4A4A4A),
             ),
           )
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String emoji, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6BB5E5) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: isSelected ? Colors.white : const Color(0xFF6A6A6A),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
             Icon(icon, size: 14, color: const Color(0xFF6BB5E5)),
             const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A7184),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return SizedBox(
      height: 48,
      child: TextField(
        style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF3F3F3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6BB5E5)),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BB5E5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height), 
      const Radius.circular(12)
    );
    
    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();
    
    double defaultDashLength = 6.0;
    double defaultDashSpace = 6.0;
    double distance = 0.0;
    
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + defaultDashLength),
          Offset.zero,
        );
        distance += defaultDashLength + defaultDashSpace;
      }
      distance = 0.0;
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
