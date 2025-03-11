import React from 'react';
import { View, StyleSheet } from 'react-native';
import { ThemedText } from '@/components/ThemedText';

interface ProfileNameProps {
  displayName: string;
}

const ProfileName: React.FC<ProfileNameProps> = ({ displayName }) => {
  const styles = StyleSheet.create({
    name: {
      fontSize: 20,
      fontWeight: 'bold',
      marginLeft: 15,
    },
  });

  return (
    <ThemedText type="defaultBold" style={styles.name}>
      {displayName}
    </ThemedText>
  );
};

export default ProfileName; 