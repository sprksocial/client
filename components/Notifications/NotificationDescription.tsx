import { NotificationProps } from '@/types/Interfaces';
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { ThemedText } from '../ThemedText';

const NotificationDescription: React.FC<{ notification: NotificationProps }> = ({ notification }) => {
  const formattedTimestamp = notification.content?.timestamp
    ? formatDistanceToNow(parseISO(notification.content.timestamp), { addSuffix: true })
    : 'Just now';

  return (
    <View>
      <ThemedText style={styles.timestamp}>{formattedTimestamp}</ThemedText>
    </View>
  );
};

const styles = StyleSheet.create({
 
  description: {
    fontSize: 14,
    color: '#ffffff',
  },
  timestamp: {
    fontSize: 12,
    color: '#aaa',
  },
});

export default NotificationDescription;
