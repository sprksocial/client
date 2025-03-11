import React from 'react';
import { View, TouchableOpacity, StyleSheet, useColorScheme } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';

interface ProfileHeaderProps {
  title: string;
  showBackButton: boolean;
  onBackPress: () => void;
  onSettingsPress: () => void;
  isSettingsVisible: boolean;
}

const ProfileHeader = ({
  title,
  showBackButton,
  onBackPress,
  onSettingsPress,
  isSettingsVisible
}: ProfileHeaderProps) => {
  const colorScheme = useColorScheme();

  return (
    <View style={styles.profileNavbar}>
      <TouchableOpacity onPress={onBackPress}>
        <Ionicons
          name="chevron-back"
          size={24}
          color={Colors[colorScheme ?? 'light'].text}
          style={{ opacity: showBackButton ? 1 : 0 }}
        />
      </TouchableOpacity>

      <ThemedText style={styles.profileTopText}>
        {title}
      </ThemedText>

      <TouchableOpacity onPress={onSettingsPress}>
        {isSettingsVisible ? (
          <Ionicons
            name="settings-outline"
            size={24}
            color={Colors[colorScheme ?? 'light'].text}
          />
        ) : (
          <Ionicons
            name="ellipsis-horizontal"
            size={24}
            color={Colors[colorScheme ?? 'light'].text}
          />
        )}
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  profileNavbar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginBottom: 10,
  },
  profileTopText: {
    fontSize: 24,
    paddingTop: 2,
  },
});

export default ProfileHeader; 