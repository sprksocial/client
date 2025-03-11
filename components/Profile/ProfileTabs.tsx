import React from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';

interface ProfileTabsProps {
  activeTab: 'videos' | 'photos';
  onTabChange: (tab: 'videos' | 'photos') => void;
}

const ProfileTabs = ({ activeTab, onTabChange }: ProfileTabsProps) => {
  const colorScheme = useColorScheme();

  return (
    <View style={styles.profileTabs}>
      <TouchableOpacity
        style={styles.tabButton}
        onPress={() => onTabChange('videos')}
      >
        <Ionicons
          name="film"
          size={24}
          color={
            activeTab === 'videos'
              ? Colors[colorScheme ?? 'light'].selectedIcon
              : Colors[colorScheme ?? 'light'].notSelectedIcon
          }
        />
        <ThemedText
          style={{
            color:
              activeTab === 'videos'
                ? Colors[colorScheme ?? 'light'].selectedIcon
                : Colors[colorScheme ?? 'light'].notSelectedIcon,
            marginLeft: 5,
          }}
        >
          Videos
        </ThemedText>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.tabButton}
        onPress={() => onTabChange('photos')}
      >
        <Ionicons
          name="image"
          size={24}
          color={
            activeTab === 'photos'
              ? Colors[colorScheme ?? 'light'].selectedIcon
              : Colors[colorScheme ?? 'light'].notSelectedIcon
          }
        />
        <ThemedText
          style={{
            color:
              activeTab === 'photos'
                ? Colors[colorScheme ?? 'light'].selectedIcon
                : Colors[colorScheme ?? 'light'].notSelectedIcon,
            marginLeft: 5,
          }}
        >
          Photos
        </ThemedText>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  profileTabs: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 10,
    width: '100%',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(150, 150, 150, 0.2)',
  },
  tabButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
  },
});

export default ProfileTabs; 