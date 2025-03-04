import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView } from 'react-native';

export default function Login() {

  useColorScheme();
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    text: {
      fontSize: 18,
      fontWeight: 'bold',
      color: '#333',
    },
  });

  const [email, setEmail] = useState('');

  const [password, setPassword] = useState('');

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity
        onPress={() => router.back()}
        style={{ position: 'absolute', top: 80, left: 20, zIndex: 1 }}>
        <Ionicons name="chevron-back" size={24} color={Colors[colorScheme ?? 'light'].text} />
      </TouchableOpacity>
      <Logo size={14} color={Colors[colorScheme ?? 'light'].selectedIcon} style={{ marginBottom: 50 }} />
      <View style={{ width: '80%' }}>
        <InputArea
          label='Email'
          placeholder='Enter your email'
          icon='mail'
          type='email'
          inputStyle={{ width: '100%' }}
          value={email}
          onChangeText={setEmail}
          style={{ width: "100%" }}
        />
        <InputArea
          label='Password'
          placeholder='Enter your password'
          icon='lock-closed'
          type='password'
          inputStyle={{ width: '100%' }}
          value={password}
          onChangeText={setPassword}
          style={{ width: "100%", marginBottom: 30 }}
        />

        <ActionButton
          title="Login"
          onPress={() => {

          }}
        />
      </View>
    </SafeAreaView>
  );
}