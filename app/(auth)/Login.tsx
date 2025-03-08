import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { pdsLogin } from '@/api/pdsAuth';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView, Alert, ActivityIndicator } from 'react-native';

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
    errorText: {
      color: 'red',
      marginBottom: 10,
      textAlign: 'center',
    },
  });

  const [handle, setHandle] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async () => {
    if (!handle || !password) {
      setError('Please enter both handle and password');
      return;
    }

    try {
      setLoading(true);
      setError('');

      // Call the pdsLogin function from our API
      await pdsLogin(handle, password);

      // If successful, navigate to the app's main screen
      router.replace('/(tabs)');
    } catch (err) {
      console.error('Login error:', err);
      setError(err instanceof Error ? err.message : 'Failed to login. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity
        onPress={() => router.back()}
        style={{ position: 'absolute', top: 80, left: 20, zIndex: 1 }}>
        <Ionicons name="chevron-back" size={24} color={Colors[colorScheme ?? 'light'].text} />
      </TouchableOpacity>
      <Logo size={14} color={Colors[colorScheme ?? 'light'].selectedIcon} style={{ marginBottom: 50 }} />
      <View style={{ width: '80%' }}>
        {error ? <ThemedText style={styles.errorText}>{error}</ThemedText> : null}

        <InputArea
          label='Handle'
          placeholder='username.bsky.social'
          icon='at'
          type='text'
          inputStyle={{ width: '100%' }}
          value={handle}
          onChangeText={setHandle}
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
          title={loading ? "Logging in..." : "Login"}
          onPress={handleLogin}
          disabled={loading}
        />

        {loading && <ActivityIndicator size="large" color={Colors[colorScheme ?? 'light'].tint} style={{ marginTop: 20 }} />}

        <TouchableOpacity
          onPress={() => router.push('/(auth)/Register')}
          style={{ marginTop: 20, alignItems: 'center' }}
        >
          <ThemedText>Don't have an account? Register</ThemedText>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}