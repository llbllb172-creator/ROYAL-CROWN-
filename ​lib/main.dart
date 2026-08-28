import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const RoyalCrownApp());
}

class RoyalCrownApp extends StatefulWidget {
  const RoyalCrownApp({super.key});

  @override
  State<RoyalCrownApp> createState() => _RoyalCrownAppState();
}

class _RoyalCrownAppState extends State<RoyalCrownApp> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Royal Crown',
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.amber,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorSchemeSeed: Colors.amber,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080808),
        ),
      ),

      home: HomeScreen(
        onThemeChanged: (mode) {
          setState(() => themeMode = mode);
        },
      ),
    );
  }
}

/* =========================================================
                      HOME SCREEN
========================================================= */

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page = 0;

  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Royal Team',
      'message': 'Welcome to Royal Crown 👑',
      'time': '1:30 PM',
      'unread': 3,
      'group': true,
    },
    {
      'name': 'Ahsan',
      'message': 'See you later',
      'time': '12:10 PM',
      'unread': 1,
      'group': false,
    },
    {
      'name': 'Ali',
      'message': 'Photo received',
      'time': '11:45 AM',
      'unread': 0,
      'group': false,
    },
    {
      'name': 'Family',
      'message': 'Good morning ❤️',
      'time': '10:20 AM',
      'unread': 5,
      'group': true,
    },
  ];

  final List<Map<String, dynamic>> vault = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Royal Crown 👑',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(chats),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: openVault,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: showMenuOptions,
          ),
        ],
      ),

      body: IndexedStack(
        index: page,
        children: [
          chatList(),
          statusPage(),
          callsPage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) {
          setState(() => page = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: newChat,
        child: const Icon(Icons.chat),
      ),
    );
  }

  /* =========================================================
                         CHATS
  ========================================================= */

  Widget chatList() {
    if (chats.isEmpty) {
      return const Center(
        child: Text('No chats'),
      );
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),

          leading: CircleAvatar(
            radius: 27,
            child: Icon(
              chat['group']
                  ? Icons.groups
                  : Icons.person,
            ),
          ),

          title: Text(
            chat['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Row(
            children: [
              const Icon(
                Icons.done_all,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  chat['message'],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(chat['time']),
              if (chat['unread'] > 0)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: Text(
                    '${chat['unread']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  name: chat['name'],
                ),
              ),
            );
          },

          onLongPress: () {
            showChatOptions(chat, index);
          },
        );
      },
    );
  }

  /* =========================================================
                      CHAT OPTIONS
  ========================================================= */

  void showChatOptions(
    Map<String, dynamic> chat,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text(
                  'Move to Private Vault',
                ),
                onTap: () {
                  setState(() {
                    vault.add(chat);
                    chats.removeAt(index);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Moved to Private Vault 🔐',
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Pin Chat'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Mute'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Chat'),
                onTap: () {
                  setState(() {
                    chats.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /* =========================================================
                         PRIVATE VAULT
  ========================================================= */

  Future<void> openVault() async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock),
              SizedBox(width: 10),
              Text('Private Vault'),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your Private Vault PIN',
              ),

              const SizedBox(height: 15),

              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () async {
                final auth = LocalAuthentication();

                try {
                  final available =
                      await auth.canCheckBiometrics;

                  if (available) {
                    final authenticated =
                        await auth.authenticate(
                      localizedReason:
                          'Unlock Royal Crown Private Vault',
                      options:
                          const AuthenticationOptions(
                        biometricOnly: true,
                        stickyAuth: true,
                      ),
                    );

                    if (authenticated &&
                        context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                } catch (_) {}
              },
              child: const Text('Fingerprint'),
            ),

            FilledButton(
              onPressed: () {
                // Demo PIN: 1234
                if (pinController.text == '1234') {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Wrong PIN. Demo PIN is 1234',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VaultScreen(
            items: vault,
          ),
        ),
      );
    }
  }

  /* =========================================================
                           STATUS
  ========================================================= */

  Widget statusPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          title: const Text(
            'My Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'Tap to add status update',
          ),
          onTap: addStatus,
        ),

        const Divider(),

        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Recent updates',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        statusTile(
          'Ahsan',
          '5 minutes ago',
        ),

        statusTile(
          'Ali',
          '20 minutes ago',
        ),

        statusTile(
          'Family',
          '1 hour ago',
        ),
      ],
    );
  }

  Widget statusTile(
    String name,
    String time,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.amber,
            width: 3,
          ),
        ),
        child: const CircleAvatar(
          child: Icon(Icons.person),
        ),
      ),
      title: Text(name),
      subtitle: Text(time),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewer(name: name),
          ),
        );
      },
    );
  }

  void addStatus() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo / Video'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Status'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /* =========================================================
                            CALLS
  ========================================================= */

  Widget callsPage() {
    return ListView(
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text('Ahsan'),
          subtitle: const Text(
            'Today, 1:20 PM',
          ),
          trailing: const Icon(Icons.call),
          onTap: () => callUser('Ahsan'),
        ),

        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text('Ali'),
          subtitle: const Text(
            'Yesterday, 8:10 PM',
          ),
          trailing: const Icon(Icons.videocam),
          onTap: () => videoCall('Ali'),
        ),
      ],
    );
  }

  void callUser(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Calling $name'),
        content: const Icon(
          Icons.call,
          size: 70,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void videoCall(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Video Calling $name'),
        content: const Icon(
          Icons.videocam,
          size: 70,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  /* =========================================================
                         NEW CHAT
  ========================================================= */

  void newChat() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Chat'),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Phone number or Gmail',
            hintText: '+92... / user@gmail.com',
            border: OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () {
              final id = controller.text.trim();

              if (id.isEmpty) return;

              setState(() {
                chats.insert(
                  0,
                  {
                    'name': id,
                    'message':
                        'Start a secure conversation',
                    'time': 'Now',
                    'unread': 0,
                    'group': false,
                  },
                );
              });

              Navigator.pop(context);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  /* =========================================================
                           MENU
  ========================================================= */

  void showMenuOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  profile();
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Private Vault'),
                onTap: () {
                  Navigator.pop(context);
                  openVault();
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  settings();
                },
              ),

              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Encrypted Backup'),
                onTap: () {
                  Navigator.pop(context);
                  backupInfo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void settings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void backupInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encrypted Backup'),
        content: const Text(
          'Royal Crown can be connected to encrypted cloud '
          'backup services. A true long-term backup system '
          'requires your own cloud infrastructure, key '
          'management and periodic restore testing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
                         CHAT SCREEN
========================================================= */

class ChatScreen extends StatefulWidget {
  final String name;

  const ChatScreen({
    super.key,
    required this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': 'Welcome to Royal Crown 👑',
      'mine': false,
      'viewOnce': false,
    },
    {
      'text': 'This is a secure chat.',
      'mine': true,
      'viewOnce': false,
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'text': text,
        'mine': true,
        'viewOnce': false,
      });

      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Text(widget.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message['mine']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: GestureDetector(
                    onLongPress: () {
                      messageOptions(message);
                    },

                    child: Container(
                      margin:
                          const EdgeInsets.only(bottom: 8),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                      constraints:
                          const BoxConstraints(
                        maxWidth: 300,
                      ),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(18),

                        color: message['mine']
                            ? Colors.amber
                            : Colors.grey.shade800,
                      ),

                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color: message['mine']
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
              ),

              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions,
                    ),
                    onPressed: () {},
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                    ),
                    onPressed: () {},
                  ),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration:
                          const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {},
                  ),

                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void messageOptions(
    Map<String, dynamic> message,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('View Once'),
              onTap: () {
                setState(() {
                  message['viewOnce'] = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                setState(() {
                  messages.remove(message);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
                       VAULT SCREEN
========================================================= */

class VaultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const VaultScreen({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Private Vault 🔐',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Private Vault is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Long-press a chat to move it here.',
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.lock),
                  ),
                  title: Text(item['name']),
                  subtitle: Text(
                    item['message'],
                  ),
                  trailing: const Icon(
                    Icons.enhanced_encryption,
                  ),
                );
              },
            ),
    );
  }
}

/* =========================================================
                     STATUS VIEWER
========================================================= */

class StatusViewer extends StatelessWidget {
  final String name;

  const StatusViewer({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(name),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(25),
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Colors.amber,
                Colors.deepOrange,
              ],
            ),
          ),
          child: const Center(
            child: Text(
              'Royal Crown Status 👑',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================================================
                         PROFILE
========================================================= */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),

          const Center(
            child: CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Name'),
            subtitle: Text('Royal Crown User'),
          ),

          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text(
              'Available on Royal Crown 👑',
            ),
          ),

          const ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text('+92XXXXXXXXXX'),
          ),

          const ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text('user@example.com'),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
                         SETTINGS
========================================================= */

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Account'),
            subtitle: Text(
              'Phone number / Gmail',
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text(
              'Dark / Light / AMOLED',
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        title: const Text('Light'),
                        leading:
                            const Icon(Icons.light_mode),
                        onTap: () {
                          onThemeChanged(
                            ThemeMode.light,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Dark'),
                        leading:
                            const Icon(Icons.dark_mode),
                        onTap: () {
                          onThemeChanged(
                            ThemeMode.dark,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('System'),
                        leading:
                            const Icon(Icons.phone_android),
                        onTap: () {
                          onThemeChanged(
                            ThemeMode.system,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Private Folder'),
            subtitle: const Text(
              'PIN / Fingerprint protection',
            ),
            onTap: () {},
          ),

          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
          ),

          const ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chats'),
          ),

          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy'),
          ),

          const ListTile(
            leading: Icon(Icons.translate),
            title: Text('AI Translation'),
            subtitle: Text(
              'Speech → Translation → Voice',
            ),
          ),

          const ListTile(
            leading: Icon(Icons.call),
            title: Text('Calls'),
            subtitle: Text(
              'HD Voice & Video',
            ),
          ),

          const ListTile(
            leading: Icon(Icons.backup),
            title: Text('Encrypted Backup'),
            subtitle: Text(
              'Long-term encrypted recovery',
            ),
          ),

          const ListTile(
            leading: Icon(Icons.ads_click),
            title: Text('Advertisements'),
            subtitle: Text(
              'Optional AdMob integration',
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
                       SEARCH DELEGATE
========================================================= */

class ChatSearchDelegate
    extends SearchDelegate<String> {
  final List<Map<String, dynamic>> chats;

  ChatSearchDelegate(this.chats);

  @override
  List<Widget>? buildActions(
    BuildContext context,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(
    BuildContext context,
  ) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    final results = chats.where((chat) {
      return chat['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: results.map((chat) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(chat['name']),
          subtitle: Text(chat['message']),
          onTap: () {
            close(context, chat['name']);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    return buildResults(context);
  }
}
