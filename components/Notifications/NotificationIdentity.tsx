import { Colors } from '@/constants/Colors';
import { NotificationProps } from '@/types/Interfaces';
import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { StyleSheet, useColorScheme, View } from 'react-native';

const NotificationIdentity: React.FC<{notification: NotificationProps}> = (
  { notification }
) => {
  let iconName: 'heart' | 'person-add' | 'chatbubble' | 'notifications';
  let iconColor: string;
  
    const colorScheme = useColorScheme();

  switch (notification.identity) {
    case 'like':
      iconName = 'heart';
      iconColor = Colors[colorScheme ?? 'light'].heartColor;
      break;
    case 'follow':
      iconName = 'person-add';
      iconColor = Colors[colorScheme ?? 'light'].followColor;
      break;
    case 'comment':
      iconName = 'chatbubble';
      iconColor = Colors[colorScheme ?? 'light'].commentColor;
      break;
    default:
      iconName = 'notifications';
      iconColor = Colors[colorScheme ?? 'light'].notSelectedIcon;
  }

  return (
    <View style={styles.container}>
      <Ionicons name={iconName} size={28} color={iconColor} style={styles.icon} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginRight: 5,
    justifyContent: 'flex-start',
    alignItems: 'center',
  },
  icon: {
    marginTop: 1,
  },
});

export default NotificationIdentity;
