import { ThemedText } from '@/components/ThemedText';
import React from 'react';
import { View, StyleSheet } from 'react-native';

export default function Register() {

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#fff',
    },
    text: {
      fontSize: 18,
      fontWeight: 'bold',
      color: '#333',
    },
  });

  return (
    <View style={styles.container}>
      <ThemedText style={styles.text}>Hello from Register!</ThemedText>
    </View>
  );
}