import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String title = '';
  String description = '';
  String? imagePath;
  bool isTeamEvent = false;
  DateTime? eventDate;
  TimeOfDay? eventTime;
  String? selectedTerrain;
  List<String> selectedUsers = [];
  List<String> selectedTeams = [];

  final List<String> terrains = [
    'Central Park Field',
    'Downtown Arena',
    'City Stadium',
    'Riverside Grounds',
    'University Field',
  ];

  final List<String> users = [
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Williams',
    'Alex Brown',
  ];

  final List<String> teams = [
    'Red Team',
    'Blue Team',
    'Green Team',
    'Yellow Team',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Progress indicator section with image background
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16), // Reduced top padding
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.webp'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8),
                  BlendMode.lighten,
                ),
              ),
            ),
            child: Column(
              children: [
                // Step labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final isActive = _currentPage >= index;
                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive 
                                ? colors.primary 
                                : Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive 
                                    ? colors.onPrimary 
                                    : colors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStepLabel(index),
                          style: textTheme.labelSmall?.copyWith(
                            color: isActive ? colors.primary : Colors.black,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Progress bar with big shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      backgroundColor: colors.surfaceContainerHighest.withOpacity(0.5),
                      color: colors.primary,
                      minHeight: 8, // Slightly thicker
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildBasicInfoPage(),
                _buildDateTimePage(),
                _buildTerrainPage(),
                _buildParticipantsPage(),
                _buildReviewPage(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colors.outline),
                    ),
                    child: Text(
                      'BACK',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 100),

                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: colors.primary.withOpacity(0.3),
                  ),
                  child: Text(
                    _currentPage == 4 ? 'CREATE EVENT' : 'CONTINUE',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _getStepLabel(int index) {
    switch (index) {
      case 0:
        return 'Details';
      case 1:
        return 'Date/Time';
      case 2:
        return 'Location';
      case 3:
        return 'Invitees';
      case 4:
        return 'Review';
      default:
        return '';
    }
  }

  Widget _buildBasicInfoPage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the basic information about your event',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Title field
          Text(
            'Event Title',
            style: textTheme.labelLarge?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter a catchy title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
            ),
            style: textTheme.bodyLarge,
            onChanged: (value) => title = value,
          ),
          const SizedBox(height: 20),

          // Description field
          Text(
            'Description',
            style: textTheme.labelLarge?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Tell participants about the event',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
            ),
            maxLines: 3,
            style: textTheme.bodyLarge,
            onChanged: (value) => description = value,
          ),
          const SizedBox(height: 24),

          // Image picker
          Row(
            children: [
              Icon(Icons.image, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Event Cover Image',
                style: textTheme.labelLarge?.copyWith(color: colors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.2),
                border: Border.all(
                  color: colors.outline.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  imagePath == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Cover Image',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recommended size: 1200x600px',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: colors.error,
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 24),

          // Event type toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Type',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTeamEvent ? 'Team Event' : 'Individual Event',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: isTeamEvent,
                  onChanged: (value) => setState(() => isTeamEvent = value),
                  activeColor: colors.primary,
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (states) =>
                        states.contains(WidgetState.selected)
                            ? Icon(Icons.group, color: colors.onPrimary)
                            : Icon(Icons.person, color: colors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date & Time',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When will your event take place?',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Date picker card
          _buildDateTimeCard(
            icon: Icons.calendar_month_outlined,
            title: 'Event Date',
            value:
                eventDate == null
                    ? 'Not selected'
                    : '${_getWeekday(eventDate!.weekday)}, ${eventDate!.day}/${eventDate!.month}/${eventDate!.year}',
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      dialogTheme: DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: colors.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => eventDate = date);
              }
            },
          ),
          const SizedBox(height: 16),

          // Time picker card
          _buildDateTimeCard(
            icon: Icons.access_time_outlined,
            title: 'Event Time',
            value:
                eventTime == null
                    ? 'Not selected'
                    : '${eventTime!.hour}:${eventTime!.minute.toString().padLeft(2, '0')}',
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now().replacing(
                  hour: TimeOfDay.now().hour + 1,
                  minute: 0,
                ),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      dialogTheme: DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: colors.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => eventTime = time);
              }
            },
          ),

          // Summary card
          if (eventDate != null && eventTime != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primaryContainer),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Scheduled',
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getWeekday(eventDate!.weekday)}, '
                          '${eventDate!.day}/${eventDate!.month}/${eventDate!.year} '
                          'at ${eventTime!.hour}:${eventTime!.minute.toString().padLeft(2, '0')}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTerrainPage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Event Location',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Choose where your event will take place',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: terrains.length,
            itemBuilder: (context, index) {
              final terrain = terrains[index];
              final isSelected = selectedTerrain == terrain;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected
                              ? colors.primary
                              : colors.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  color:
                      isSelected
                          ? colors.primary.withOpacity(0.05)
                          : colors.surface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => selectedTerrain = terrain),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? colors.primary
                                      : colors.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color:
                                  isSelected
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  terrain,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected
                                            ? colors.primary
                                            : colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capacity: 50-100 people',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsPage() {
    return isTeamEvent ? _buildTeamsPage() : _buildUsersPage();
  }

  Widget _buildUsersPage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Invite Participants',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select who you want to invite to your event',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = selectedUsers.contains(user);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected
                              ? colors.primary
                              : colors.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  color:
                      isSelected
                          ? colors.primary.withOpacity(0.05)
                          : colors.surface,
                  child: CheckboxListTile(
                    title: Text(
                      user,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Football enthusiast',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_outline, color: colors.primary),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(user);
                        } else {
                          selectedUsers.remove(user);
                        }
                      });
                    },
                    activeColor: colors.primary,
                    checkColor: colors.onPrimary,
                    controlAffinity: ListTileControlAffinity.trailing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsPage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Invite Teams',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select which teams you want to invite',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isSelected = selectedTeams.contains(team);
              Color teamColor;

              switch (team) {
                case 'Red Team':
                  teamColor = colors.error;
                  break;
                case 'Blue Team':
                  teamColor = colors.primary;
                  break;
                case 'Green Team':
                  teamColor = colors.tertiary;
                  break;
                case 'Yellow Team':
                  teamColor = colors.secondary;
                  break;
                default:
                  teamColor = colors.surfaceContainerHighest;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected
                              ? teamColor
                              : colors.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  color:
                      isSelected ? teamColor.withOpacity(0.05) : colors.surface,
                  child: CheckboxListTile(
                    title: Text(
                      team,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${index + 2} members',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: teamColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.group_outlined, color: teamColor),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedTeams.add(team);
                        } else {
                          selectedTeams.remove(team);
                        }
                      });
                    },
                    activeColor: teamColor,
                    checkColor: colors.onPrimary,
                    controlAffinity: ListTileControlAffinity.trailing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewPage() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Event',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all the details before creating your event',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagePath!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: colors.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: colors.error,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),

          // Event details section
          _buildReviewSection(
            icon: Icons.event_outlined,
            title: 'Event Details',
            children: [
              _buildReviewItem('Title', title),
              if (description.isNotEmpty)
                _buildReviewItem('Description', description),
              _buildReviewItem(
                'Type',
                isTeamEvent ? 'Team Event' : 'Individual Event',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date & Time section
          if (eventDate != null && eventTime != null)
            _buildReviewSection(
              icon: Icons.access_time_outlined,
              title: 'Date & Time',
              children: [
                _buildReviewItem(
                  'Date',
                  '${_getWeekday(eventDate!.weekday)}, ${eventDate!.day}/${eventDate!.month}/${eventDate!.year}',
                ),
                _buildReviewItem(
                  'Time',
                  '${eventTime!.hour}:${eventTime!.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Location section
          if (selectedTerrain != null)
            _buildReviewSection(
              icon: Icons.location_on_outlined,
              title: 'Location',
              children: [_buildReviewItem('Venue', selectedTerrain!)],
            ),
          const SizedBox(height: 16),

          // Participants section
          _buildReviewSection(
            icon: isTeamEvent ? Icons.group_outlined : Icons.people_outline,
            title: isTeamEvent ? 'Invited Teams' : 'Invited Participants',
            children:
                isTeamEvent
                    ? selectedTeams
                        .map((team) => _buildReviewItem('Team', team))
                        .toList()
                    : selectedUsers
                        .map((user) => _buildReviewItem('Participant', user))
                        .toList(),
          ),

          const SizedBox(height: 24),

          // Terms checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: true,
                onChanged: (value) {},
                activeColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I confirm that all the information provided is accurate and I agree to the terms of service.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _pickImage() {
    // Implement image picking logic
    setState(() {
      imagePath =
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=600&auto=format&fit=crop';
    });
  }

  void _nextPage() {
    if (_currentPage < 4) {
      // Validate current page before proceeding
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitForm();
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Basic info
        if (title.isEmpty) {
          _showValidationError('Please enter an event title');
          return false;
        }
        return true;
      case 1: // Date & Time
        if (eventDate == null || eventTime == null) {
          _showValidationError('Please select both date and time');
          return false;
        }
        return true;
      case 2: // Terrain
        if (selectedTerrain == null) {
          _showValidationError('Please select a location');
          return false;
        }
        return true;
      case 3: // Participants
        if ((isTeamEvent && selectedTeams.isEmpty) ||
            (!isTeamEvent && selectedUsers.isEmpty)) {
          _showValidationError('Please select at least one participant');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    // Implement form submission logic

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            title: const Text('Event Created!'),
            content: const Text(
              'Your event has been successfully created and invitations have been sent.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close form
                },
                child: const Text('OK'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }
}
