import { NotificationProps } from '@/types/Interfaces';
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { ThemedText } from '../ThemedText';

const NotificationTitle: React.FC<{ notification: NotificationProps }> = ({ notification }) => {
  const { type, content } = notification;
  const users = content?.users || [];
  const firstUser = users.length > 0 ? users[0].name : 'Someone';
  const othersCount = users.length > 1 ? users.length - 1 : 0;

  let title = '';

  switch (type?.typeName) {
    case 'single_user_like':
      title = `${firstUser} liked your video`;
      break;
    case 'single_user_comment':
      title = `${firstUser} commented on your video`;
      break;
    case 'single_user_follow':
      title = `${firstUser} followed you`;
      break;
    case 'single_user_reply':
      title = `${firstUser} replied to your comment`;
      break;
    case 'multiple_user_like':
      title = othersCount > 0 ? `${firstUser} and ${othersCount} others liked your video` : `${firstUser} liked your video`;
      break;
    case 'multiple_user_follow':
      title = othersCount > 0 ? `${firstUser} and ${othersCount} others followed you` : `${firstUser} followed you`;
      break;
    case 'multiple_user_reply':
      title = othersCount > 0 ? `${firstUser} and ${othersCount} others replied to your comment` : `${firstUser} replied to your comment`;
      break;
    default:
      title = `${firstUser} sent you a notification`;
  }

  return (
    <View style={styles.container}>
      <ThemedText style={styles.text}>{title}</ThemedText>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  text: {
    fontSize: 16,
  },
});

export default NotificationTitle;
