import React from 'react';
import { View, StyleSheet, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { UserProps } from '@/types/Interfaces';
import { Colors } from '@/constants/Colors';

const formatNumber = (num?: number) => {
    if (!num) return '0';
    if (num >= 1_000_000_000) return (num / 1_000_000_000).toFixed(1) + 'B';
    if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
    if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
    return num.toString();
  };

const ProfileInfo: React.FC<{ userData: UserProps }> = ({ userData }) => {
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      alignItems: 'center',
      padding: 10,
      width: '100%',
    },
    nameContainer: {
      alignItems: 'center',
      width: '80%',
      marginBottom: 4,
    },
    name: {
      fontSize: 18,
      fontWeight: 'bold',
    },
    handler: {
      fontSize: 14,
      color: Colors[colorScheme ?? 'light'].textGray,
      borderRadius: 4,
      paddingVertical: 2,
      paddingHorizontal: 8,
    },
    statsContainer: {
      marginTop: 5,
      flexDirection: 'row',
      justifyContent: 'space-between',
      width: '70%',
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
    bioContainer: {
      marginVertical: 4,
      width: '80%',
    },
    bio: {
      fontSize: 14,
      color: '#888',
      textAlign: 'center',
    },
  });

  return (
    <View style={styles.container}>
      <View style={styles.nameContainer}>
      <ThemedText type="defaultBold" style={styles.name}>{userData.name}</ThemedText>
      <ThemedText type="username" style={styles.handler}>@{userData.handler}</ThemedText>
      </View>

      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <ThemedText type="defaultBold" style={styles.statNumber}>{formatNumber(userData.following ?? 0)}</ThemedText>
          <ThemedText type="default" style={styles.statLabel}>Following</ThemedText>
        </View>
        <View style={styles.statItem}>
          <ThemedText type="defaultBold" style={styles.statNumber}>{formatNumber(userData.followers ?? 0)}</ThemedText>
          <ThemedText type="default" style={styles.statLabel}>Followers</ThemedText>
        </View>
        <View style={styles.statItem}>
          <ThemedText type="defaultBold" style={styles.statNumber}>{formatNumber(userData.likes ?? 0)}</ThemedText>
          <ThemedText type="default" style={styles.statLabel}>Likes</ThemedText>
        </View>
      </View>
      <View style={styles.bioContainer}>
        <ThemedText type="default" style={styles.bio}>{userData.bio}</ThemedText>
      </View>
    </View>
  );
};



export default ProfileInfo;
