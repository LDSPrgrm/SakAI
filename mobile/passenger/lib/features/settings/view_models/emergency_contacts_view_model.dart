import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/emergency_contact.dart';

/// Key for storing emergency contacts in SharedPreferences.
const String _contactsKey = 'emergency_contacts';

/// State of the emergency contacts.
class EmergencyContactsState {
  const EmergencyContactsState({this.contacts = const [], this.errorMessage});

  final List<EmergencyContactModel> contacts;
  final String? errorMessage;

  EmergencyContactsState copyWith({
    List<EmergencyContactModel>? contacts,
    String? errorMessage,
  }) {
    return EmergencyContactsState(
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage,
    );
  }

  bool get canAddMore => contacts.length < 3;
}

/// Notifier for managing emergency contacts.
class EmergencyContactsNotifier extends Notifier<EmergencyContactsState> {
  @override
  EmergencyContactsState build() {
    _loadContacts();
    return const EmergencyContactsState();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_contactsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final contacts = jsonList
            .map((json) => EmergencyContactModel.fromJson(json))
            .toList();
        state = state.copyWith(contacts: contacts);
      }
    } catch (e) {
      debugPrint('[EmergencyContactsNotifier] Error loading contacts: $e');
      state = state.copyWith(errorMessage: 'Failed to load emergency contacts');
    }
  }

  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.contacts.map((c) => c.toJson()).toList();
      await prefs.setString(_contactsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[EmergencyContactsNotifier] Error saving contacts: $e');
    }
  }

  /// Adds a new emergency contact. Returns true if successful.
  Future<bool> addContact(EmergencyContactModel contact) async {
    if (!state.canAddMore) {
      state = state.copyWith(
        errorMessage: 'Maximum of 3 emergency contacts allowed',
      );
      return false;
    }

    final updatedContacts = [...state.contacts, contact];
    state = state.copyWith(contacts: updatedContacts);
    await _saveContacts();
    return true;
  }

  /// Updates an existing emergency contact.
  Future<void> updateContact(EmergencyContactModel updatedContact) async {
    final updatedContacts = state.contacts
        .map((c) => c.id == updatedContact.id ? updatedContact : c)
        .toList();
    state = state.copyWith(contacts: updatedContacts);
    await _saveContacts();
  }

  /// Removes an emergency contact by ID.
  Future<void> removeContact(String contactId) async {
    final updatedContacts = state.contacts
        .where((c) => c.id != contactId)
        .toList();
    state = state.copyWith(contacts: updatedContacts);
    await _saveContacts();
  }

  /// Refreshes contacts from storage.
  Future<void> refresh() async {
    await _loadContacts();
  }
}

/// Riverpod provider for the EmergencyContactsNotifier.
final emergencyContactsProvider =
    NotifierProvider<EmergencyContactsNotifier, EmergencyContactsState>(
      EmergencyContactsNotifier.new,
    );
