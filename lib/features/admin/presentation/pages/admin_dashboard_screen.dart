import 'package:event_planner/features/admin/presentation/pages/admin_chat_conversation_screen.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';
import 'package:event_planner/features/admin/presentation/state/admin_state.dart';
import 'package:event_planner/features/admin/presentation/view_model/admin_viewmodel.dart';
import 'package:event_planner/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(adminViewModelProvider.notifier)
          .setSection(AdminSection.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminViewModelProvider);
    final vm = ref.read(adminViewModelProvider.notifier);

    ref.listen<AdminState>(adminViewModelProvider, (previous, next) {
      if (!mounted) return;
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  title: _titleFor(state.section),
                  section: state.section,
                  onGoDashboard: () => vm.setSection(AdminSection.dashboard),
                  onLogout: _logout,
                ),
                Expanded(
                  child: _SectionBody(
                    state: state,
                    vm: vm,
                    openCreateUserDialog: _openCreateUserDialog,
                    openEditUserDialog: _openEditUserDialog,
                    openCreateVenueDialog: _openCreateVenueDialog,
                  ),
                ),
              ],
            ),
            if (state.isLoading)
              const Positioned(
                right: 16,
                top: 16,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _titleFor(AdminSection section) {
    switch (section) {
      case AdminSection.dashboard:
        return 'Admin Dashboard';
      case AdminSection.users:
        return 'Admin Users';
      case AdminSection.events:
        return 'Admin Events';
      case AdminSection.venues:
        return 'Admin Venues';
      case AdminSection.chats:
        return 'Admin Chats';
    }
  }

  Future<void> _logout() async {
    await ref.read(authViewModelProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _openCreateUserDialog() async {
    final vm = ref.read(adminViewModelProvider.notifier);
    final firstName = TextEditingController();
    final lastName = TextEditingController();
    final username = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController();
    String role = 'user';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create User'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Input(controller: firstName, label: 'First Name'),
                  _Input(controller: lastName, label: 'Last Name'),
                  _Input(controller: username, label: 'Username'),
                  _Input(controller: email, label: 'Email'),
                  _Input(controller: phone, label: 'Phone Number'),
                  _Input(
                    controller: password,
                    label: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setInnerState) {
                      return DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setInnerState(() {
                            role = value ?? 'user';
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (submitted == true) {
      await vm.createUser(
        user: AdminUserEntity(
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          username: username.text.trim(),
          email: email.text.trim(),
          phoneNumber: phone.text.trim(),
          role: role,
        ),
        password: password.text.trim(),
      );
    }

    firstName.dispose();
    lastName.dispose();
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
  }

  Future<void> _openEditUserDialog(AdminUserEntity user) async {
    final vm = ref.read(adminViewModelProvider.notifier);
    final firstName = TextEditingController(text: user.firstName);
    final lastName = TextEditingController(text: user.lastName);
    final username = TextEditingController(text: user.username);
    final email = TextEditingController(text: user.email);
    final phone = TextEditingController(text: user.phoneNumber);
    String role = user.role;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Input(controller: firstName, label: 'First Name'),
                  _Input(controller: lastName, label: 'Last Name'),
                  _Input(controller: username, label: 'Username'),
                  _Input(controller: email, label: 'Email'),
                  _Input(controller: phone, label: 'Phone Number'),
                  StatefulBuilder(
                    builder: (context, setInnerState) {
                      return DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setInnerState(() {
                            role = value ?? 'user';
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (submitted == true) {
      await vm.updateUser(
        AdminUserEntity(
          id: user.id,
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          username: username.text.trim(),
          email: email.text.trim(),
          phoneNumber: phone.text.trim(),
          role: role,
          profilePicture: user.profilePicture,
        ),
      );
    }

    firstName.dispose();
    lastName.dispose();
    username.dispose();
    email.dispose();
    phone.dispose();
  }

  Future<void> _openCreateVenueDialog() async {
    final vm = ref.read(adminViewModelProvider.notifier);
    final name = TextEditingController();
    final city = TextEditingController();
    final state = TextEditingController();
    final address = TextEditingController();
    final capacity = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Venue'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Input(controller: name, label: 'Venue Name'),
                  _Input(controller: city, label: 'City'),
                  _Input(controller: state, label: 'State'),
                  _Input(controller: address, label: 'Address'),
                  _Input(
                    controller: capacity,
                    label: 'Capacity',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (submitted == true) {
      await vm.createVenue(
        AdminVenueEntity(
          name: name.text.trim(),
          city: city.text.trim(),
          state: state.text.trim(),
          address: address.text.trim(),
          capacity: int.tryParse(capacity.text.trim()),
        ),
      );
    }

    name.dispose();
    city.dispose();
    state.dispose();
    address.dispose();
    capacity.dispose();
  }
}

class _SectionBody extends StatelessWidget {
  final AdminState state;
  final AdminViewModel vm;
  final Future<void> Function() openCreateUserDialog;
  final Future<void> Function(AdminUserEntity user) openEditUserDialog;
  final Future<void> Function() openCreateVenueDialog;

  const _SectionBody({
    required this.state,
    required this.vm,
    required this.openCreateUserDialog,
    required this.openEditUserDialog,
    required this.openCreateVenueDialog,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.section) {
      case AdminSection.dashboard:
        return _DashboardPanel(onNavigate: vm.setSection);
      case AdminSection.users:
        return _UsersPanel(
          state: state,
          onCreate: openCreateUserDialog,
          onEdit: openEditUserDialog,
          onDelete: vm.deleteUser,
          onRefresh: vm.loadUsers,
        );
      case AdminSection.events:
        return _EventsPanel(
          state: state,
          onApprove: vm.approveEvent,
          onDecline: vm.declineEvent,
          onDelete: vm.deleteEvent,
          onRefresh: vm.loadEvents,
        );
      case AdminSection.venues:
        return _VenuesPanel(
          state: state,
          onCreate: openCreateVenueDialog,
          onRefresh: vm.loadVenues,
        );
      case AdminSection.chats:
        return _ChatsPanel(state: state, vm: vm);
    }
  }
}

class _DashboardPanel extends StatelessWidget {
  final ValueChanged<AdminSection> onNavigate;

  const _DashboardPanel({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Welcome to the admin dashboard. Manage Users, Events, Venues, and Chats, similar to your web admin panel.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _QuickAction(
                  icon: Icons.people_alt_rounded,
                  label: 'Users',
                  onTap: () => onNavigate(AdminSection.users),
                ),
                _QuickAction(
                  icon: Icons.event_note_rounded,
                  label: 'Events',
                  onTap: () => onNavigate(AdminSection.events),
                ),
                _QuickAction(
                  icon: Icons.location_city_rounded,
                  label: 'Venues',
                  onTap: () => onNavigate(AdminSection.venues),
                ),
                _QuickAction(
                  icon: Icons.chat_rounded,
                  label: 'Chats',
                  onTap: () => onNavigate(AdminSection.chats),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersPanel extends StatelessWidget {
  final AdminState state;
  final Future<void> Function() onCreate;
  final Future<void> Function(AdminUserEntity user) onEdit;
  final Future<void> Function(String userId) onDelete;
  final Future<void> Function() onRefresh;

  const _UsersPanel({
    required this.state,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Card(
        child: Column(
          children: [
            _HeaderBar(
              title: 'User Management',
              primaryLabel: 'Create User',
              onPrimaryTap: onCreate,
              onRefresh: onRefresh,
            ),
            const Divider(height: 1),
            Expanded(
              child: state.users.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : ListView.separated(
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFF800000,
                            ).withValues(alpha: 0.12),
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: Color(0xFF800000)),
                            ),
                          ),
                          title: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName
                                : user.username,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${user.email}\n${user.phoneNumber} • ${user.role}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                onPressed: () => onEdit(user),
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                onPressed: () => onDelete(user.id),
                                icon: const Icon(Icons.delete_rounded),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsPanel extends StatelessWidget {
  final AdminState state;
  final Future<void> Function(String eventId, {String? adminNotes}) onApprove;
  final Future<void> Function(String eventId, {String? adminNotes}) onDecline;
  final Future<void> Function(String eventId) onDelete;
  final Future<void> Function() onRefresh;

  const _EventsPanel({
    required this.state,
    required this.onApprove,
    required this.onDecline,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Card(
        child: Column(
          children: [
            _HeaderBar(title: 'Event Management', onRefresh: onRefresh),
            const Divider(height: 1),
            Expanded(
              child: state.events.isEmpty
                  ? const Center(child: Text('No events found.'))
                  : ListView.separated(
                      itemCount: state.events.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final event = state.events[index];
                        final status = event.status.toLowerCase();

                        return ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${event.location}\n${event.startDate?.toLocal().toString().split(' ').first ?? '-'} • ${event.status}',
                          ),
                          isThreeLine: true,
                          trailing: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (status != 'approved')
                                  TextButton(
                                    onPressed: () => onApprove(event.id),
                                    child: const Text('Approve'),
                                  ),
                                if (status != 'declined' &&
                                    status != 'approved')
                                  TextButton(
                                    onPressed: () => onDecline(event.id),
                                    child: const Text('Decline'),
                                  ),
                                IconButton(
                                  onPressed: () => onDelete(event.id),
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VenuesPanel extends StatelessWidget {
  final AdminState state;
  final Future<void> Function() onCreate;
  final Future<void> Function() onRefresh;

  const _VenuesPanel({
    required this.state,
    required this.onCreate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Card(
        child: Column(
          children: [
            _HeaderBar(
              title: 'Venue Management',
              primaryLabel: 'Create Venue',
              onPrimaryTap: onCreate,
              onRefresh: onRefresh,
            ),
            const Divider(height: 1),
            Expanded(
              child: state.venues.isEmpty
                  ? const Center(child: Text('No venues found.'))
                  : ListView.separated(
                      itemCount: state.venues.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final venue = state.venues[index];
                        return ListTile(
                          title: Text(
                            venue.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${venue.city}, ${venue.state}\nCapacity: ${venue.capacity ?? 0}',
                          ),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: venue.isActive
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                            ),
                            child: Text(
                              venue.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: venue.isActive
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatsPanel extends StatelessWidget {
  final AdminState state;
  final AdminViewModel vm;

  const _ChatsPanel({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Card(
        child: Column(
          children: [
            _HeaderBar(title: 'Chat Users', onRefresh: vm.loadChatUsers),
            const Divider(height: 1),
            Expanded(
              child: state.chatUsers.isEmpty
                  ? const Center(child: Text('No chats yet.'))
                  : ListView.separated(
                      itemCount: state.chatUsers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = state.chatUsers[index];
                        return ListTile(
                          onTap: () async {
                            await vm.selectChatUser(user);
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminChatConversationScreen(user: user),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFF800000,
                            ).withValues(alpha: 0.12),
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : user.username[0].toUpperCase(),
                              style: const TextStyle(color: Color(0xFF800000)),
                            ),
                          ),
                          title: Text(
                            user.fullName.isEmpty
                                ? user.username
                                : user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            user.lastMessage.isEmpty
                                ? 'No messages yet'
                                : user.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.unreadCount > 0)
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: const Color(0xFF800000),
                                  child: Text(
                                    '${user.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final AdminSection section;
  final VoidCallback onGoDashboard;
  final VoidCallback onLogout;

  const _TopBar({
    required this.title,
    required this.section,
    required this.onGoDashboard,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7E7E7))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (section != AdminSection.dashboard)
                IconButton(
                  onPressed: onGoDashboard,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF800000).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    color: Color(0xFF800000),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: child,
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF800000)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final String title;
  final String? primaryLabel;
  final Future<void> Function()? onPrimaryTap;
  final Future<void> Function()? onRefresh;

  const _HeaderBar({
    required this.title,
    this.primaryLabel,
    this.onPrimaryTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          if (primaryLabel != null && onPrimaryTap != null)
            ElevatedButton(
              onPressed: onPrimaryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                foregroundColor: Colors.white,
              ),
              child: Text(primaryLabel!),
            ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _Input({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
