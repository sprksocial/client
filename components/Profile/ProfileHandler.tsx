import React from 'react';
import { StyleSheet, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';

interface ProfileHandlerProps {
  handle: string;
}

const ProfileHandler: React.FC<ProfileHandlerProps> = ({ handle }) => {
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    handler: {
      fontSize: 16,
      fontWeight: 'bold',
      color: Colors[colorScheme ?? 'light'].textGray,
    },
  });

  if (handle === 'null') return null;

  return (
    <ThemedText type="username" style={styles.handler}>
      @{handle}
    </ThemedText>
  );
};

export default ProfileHandler; 