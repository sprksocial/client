import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { pdsRegister } from '@/api/pdsAuth';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView, Dimensions, ActivityIndicator } from 'react-native';

export default function Register() {

  useColorScheme();
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      height: Dimensions.get('screen').height,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      width: '100%',
    },
    text: {
      fontSize: 18,
      fontWeight: 'bold',
    },
    errorText: {
      color: 'red',
      marginBottom: 10,
      textAlign: 'center',
    },
  });

  const [email, setEmail] = useState('');
  const [handle, setHandle] = useState('');
  const [password, setPassword] = useState('');
  const [inviteCode, setInviteCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleRegister = async () => {
    if (!email || !handle || !password) {
      setError('Please fill in all required fields');
      return;
    }

    // Simple email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    // Simple handle validation
    if (!handle.includes('.')) {
      setError('Handle must be in format username.bsky.social');
      return;
    }

    // Password length check
    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    try {
      setLoading(true);
      setError('');

      // Call the pdsRegister function from our API
      await pdsRegister(email, handle, password, inviteCode || undefined);

      // If successful, navigate to the app's main screen
      router.replace('/(tabs)');
    } catch (err) {
      console.error('Registration error:', err);
      setError(err instanceof Error ? err.message : 'Failed to register. Please try again.');
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
      <View style={{ width: '100%', alignItems: 'center' }}>
        {error ? <ThemedText style={styles.errorText}>{error}</ThemedText> : null}

        <InputArea
          label='Email'
          placeholder='Enter your email'
          icon='mail'
          type='email'
          inputStyle={{ width: '100%' }}
          value={email}
          onChangeText={setEmail}
          style={{ width: "90%" }}
        />

        <InputArea
          label='Handle'
          placeholder='username.sprk.so'
          icon='at'
          type='text'
          inputStyle={{ width: '100%' }}
          value={handle}
          onChangeText={setHandle}
          style={{ width: "90%" }}
        />

        <InputArea
          label='Password'
          placeholder='Enter your password'
          icon='lock-closed'
          type='password'
          inputStyle={{ width: '90%' }}
          value={password}
          onChangeText={setPassword}
          style={{ width: "90%", marginBottom: 15 }}
        />

        <InputArea
          label='Invite Code (Optional)'
          placeholder='Enter invite code if you have one'
          icon='key'
          type='text'
          inputStyle={{ width: '90%' }}
          value={inviteCode}
          onChangeText={setInviteCode}
          style={{ width: "90%", marginBottom: 30 }}
        />

        <ActionButton
          title={loading ? "Registering..." : "Register"}
          onPress={handleRegister}
          disabled={loading}
          width={'90%'}
        />

        {loading && <ActivityIndicator size="large" color={Colors[colorScheme ?? 'light'].tint} style={{ marginTop: 20 }} />}

        <TouchableOpacity
          onPress={() => router.push('/(auth)/Login')}
          style={{ marginTop: 20, alignItems: 'center' }}
        >
          <ThemedText>Already have an account? Login</ThemedText>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}