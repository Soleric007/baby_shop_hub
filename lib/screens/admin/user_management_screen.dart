// lib/screens/admin/user_management_screen.dart (Updated)
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All'; // All, Users, Admins

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
    });

    final loadedUsers = await AdminService.getAllUsers();
    setState(() {
      users = loadedUsers;
      applyFilter();
      isLoading = false;
    });
  }

  void applyFilter() {
    List<Map<String, dynamic>> filtered = users;

    // Apply role filter
    if (selectedFilter == 'Users') {
      filtered = filtered.where((user) => user['role'] != 'admin').toList();
    } else if (selectedFilter == 'Admins') {
      filtered = filtered.where((user) => user['role'] == 'admin').toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((user) =>
              (user['name']?.toLowerCase() ?? '').contains(searchQuery.toLowerCase()) ||
              (user['email']?.toLowerCase() ?? '').contains(searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredUsers = filtered;
    });
  }

  void filterUsers(String query) {
    setState(() {
      searchQuery = query;
    });
    applyFilter();
  }

  void changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    applyFilter();
  }

  Future<void> deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete "${user['name'] ?? user['email']}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await AdminService.deleteUser(user['email']);
      if (success) {
        loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${user['name'] ?? user['email']} deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleAdminRole(Map<String, dynamic> user) async {
    final isAdmin = user['role'] == 'admin';
    final action = isAdmin ? 'demote from admin' : 'promote to admin';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdmin ? 'Demote Admin' : 'Promote to Admin'),
        content: Text(
          'Are you sure you want to $action "${user['name'] ?? user['email']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isAdmin ? Colors.orange : Colors.green,
            ),
            child: Text(isAdmin ? 'Demote' : 'Promote'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success;
      if (isAdmin) {
        success = await AdminService.demoteAdminToUser(user['email']);
      } else {
        success = await AdminService.promoteUserToAdmin(user['email']);
      }

      if (success) {
        loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user['name'] ?? user['email']} ${isAdmin ? 'demoted to user' : 'promoted to admin'}',
            ),
            backgroundColor: isAdmin ? Colors.orange : Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name'] ?? 'User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', user['name'] ?? 'Not provided'),
            _buildDetailRow('Email', user['email'] ?? 'Not provided'),
            _buildDetailRow('Phone', user['phone'] ?? 'Not provided'),
            _buildDetailRow('Address', user['address'] ?? 'Not provided'),
            _buildDetailRow('Role', user['role'] ?? 'user'),
            if (user['created_at'] != null)
              _buildDetailRow('Joined', _formatDate(user['created_at'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isAdmin = user['role'] == 'admin';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.purple.shade100 : Colors.green.shade100,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: isAdmin ? Colors.purple.shade700 : Colors.green.shade700,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['name'] ?? 'Unknown User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'] ?? 'No email',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (user['phone'] != null && user['phone'].isNotEmpty)
              Text(
                user['phone'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            if (user['address'] != null && user['address'].isNotEmpty)
              Text(
                user['address'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              showUserDetails(user);
            } else if (value == 'toggle_admin') {
              toggleAdminRole(user);
            } else if (value == 'delete') {
              deleteUser(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_admin',
              child: Row(
                children: [
                  Icon(
                    isAdmin ? Icons.person : Icons.admin_panel_settings,
                    color: isAdmin ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(isAdmin ? 'Demote from Admin' : 'Promote to Admin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete User'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => showUserDetails(user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userCount = filteredUsers.where((u) => u['role'] != 'admin').length;
    final adminCount = filteredUsers.where((u) => u['role'] == 'admin').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('User Management', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: filterUsers,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'Users', label: Text('Users')),
                      ButtonSegment(value: 'Admins', label: Text('Admins')),
                    ],
                    selected: {selectedFilter},
                    onSelectionChanged: (Set<String> selection) {
                      changeFilter(selection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: Colors.green.shade100,
                      selectedForegroundColor: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.green.shade50,
            child: Row(
              children: [
                _buildStatChip('Total', '${filteredUsers.length}', Colors.blue),
                const SizedBox(width: 12),
                _buildStatChip('Users', '$userCount', Colors.green),
                const SizedBox(width: 12),
                _buildStatChip('Admins', '$adminCount', Colors.purple),
                const Spacer(),
                if (searchQuery.isNotEmpty) 
                  Text(
                    'Results for "$searchQuery"',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'No users found for "$searchQuery"'
                                  : selectedFilter == 'All'
                                      ? 'No users registered yet'
                                      : 'No ${selectedFilter.toLowerCase()} found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (searchQuery.isEmpty && selectedFilter == 'All') ...[
                              const SizedBox(height: 8),
                              Text(
                                'Users will appear here after they register',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(filteredUsers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}