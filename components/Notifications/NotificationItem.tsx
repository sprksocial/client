import React from 'react';
import { View, StyleSheet, TouchableOpacity, useColorScheme } from 'react-native';
import NotificationIdentity from './NotificationIdentity';
import NotificationHeader from './NotificationHeader';
import NotificationTitle from './NotificationTitle';
import NotificationDescription from './NotificationDescription';
import { NotificationProps } from '@/types/Interfaces';
import { Colors } from '@/constants/Colors';

const NotificationItem: React.FC<{ notification: NotificationProps }> = ({ notification }) => {
    const colorScheme = useColorScheme();
const styles = StyleSheet.create({
  container: {
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: Colors[colorScheme ?? 'light'].underlineColor,
    flexDirection: 'row',
  },
  innerContainer: {
    flex: 1,
  },
});

  return (
    <TouchableOpacity style={styles.container} onPress={() => { notification.onPress?.() }}>
      <NotificationIdentity notification={notification} />
      <View style={styles.innerContainer}>
        <NotificationHeader notification={notification} />
        <NotificationTitle notification={notification} />
        <NotificationDescription notification={notification} />
      </View>
    </TouchableOpacity>
  );
};


export default NotificationItem;
