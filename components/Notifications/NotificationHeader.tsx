import React from 'react';
import { View, Image, StyleSheet, useColorScheme } from 'react-native';
import { NotificationProps } from '@/types/Interfaces';
import { Colors } from '@/constants/Colors';

const NotificationHeader: React.FC<{ notification: NotificationProps }> = ({ notification }) => {
    const colorScheme = useColorScheme();

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  userImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 10,
  },
  userImageMultiple: {
    width: 32,
    height: 32,
    borderRadius: 15,
    marginRight: -8,
    borderWidth: 2,
    borderColor: Colors[colorScheme ?? 'light'].background,
  },
});

  const isSingleUserNotification =
    notification.type &&
    [
      'single_user_comment',
      'single_user_reply',
      'single_user_like',
      'single_user_follow',
    ].includes(notification.type?.typeName as string);

  return (
    <View style={styles.container}>
      {isSingleUserNotification && notification.content ? (
        <Image
          source={{ uri: notification.content.users[0].image }}
          style={styles.userImage}
        />
      ) : (
        notification.content &&
        notification.content.users.map((user) => (
          <Image key={user.did} source={{ uri: user.image }} style={styles.userImageMultiple} />
        ))
      )}
    </View>
  );
};


export default NotificationHeader;
