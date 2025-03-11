import React from 'react';
import { View, StyleSheet, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';

interface ProfileNumbersProps {
  followsCount?: number;
  followersCount?: number;
  likes?: number;
}

const formatNumber = (num?: number) => {
  if (!num) return '0';
  if (num >= 1_000_000_000) return (num / 1_000_000_000).toFixed(1) + 'B';
  if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
  if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
  return num.toString();
};

const ProfileNumbers: React.FC<ProfileNumbersProps> = ({
  followsCount,
  followersCount,
  likes,
}) => {
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    statsContainer: {
      marginTop: 5,
      flexDirection: 'row',
      justifyContent: 'space-between',
      width: '100%',
    },
    statItem: {
      alignItems: 'center',
      width: '33%',
      gap: 0,
    },
    statNumber: {
      fontSize: 16,
      fontWeight: 'bold',
      color: Colors[colorScheme ?? 'light'].text,
    },
    statLabel: {
      fontSize: 12,
      color: Colors[colorScheme ?? 'light'].textGray,
    },
  });

  return (
    <View style={styles.statsContainer}>
      <View style={styles.statItem}>
        <ThemedText type="defaultBold" style={styles.statNumber}>
          {formatNumber(followsCount)}
        </ThemedText>
        <ThemedText type="default" style={styles.statLabel}>
          Following
        </ThemedText>
      </View>
      <View style={styles.statItem}>
        <ThemedText type="defaultBold" style={styles.statNumber}>
          {formatNumber(followersCount)}
        </ThemedText>
        <ThemedText type="default" style={styles.statLabel}>
          Followers
        </ThemedText>
      </View>
      <View style={styles.statItem}>
        <ThemedText type="defaultBold" style={styles.statNumber}>
          {formatNumber(likes)}
        </ThemedText>
        <ThemedText type="default" style={styles.statLabel}>
          Likes
        </ThemedText>
      </View>
    </View>
  );
};

export default ProfileNumbers; 