import React from 'react';
import { View, StyleSheet } from 'react-native';

export default function PlaceholderVideoDisplay() {
  const styles = StyleSheet.create({
    container: {
      width: '32%',
      aspectRatio: 12 / 17,
      borderRadius: 2,
      marginHorizontal: 1,
      marginVertical: 1,
      backgroundColor: 'transparent',
      opacity: 0.2
    }
  });
  return <View style={styles.container} />;
}