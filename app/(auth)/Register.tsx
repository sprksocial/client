import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView, Dimensions } from 'react-native';

export default function Register() {

  useColorScheme();
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      height: Dimensions.get('screen').height,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      // backgroundColor: 'blue',
      width: '100%',
    },
    text: {
      fontSize: 18,
      fontWeight: 'bold',
    },
  });

  const [email, setEmail] = useState('');

  const [password, setPassword] = useState('');

  const [birthDate, setBirthDate] = useState('');

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity
        onPress={() => router.back()}
        style={{ position: 'absolute', top: 80, left: 20, zIndex: 1 }}>
        <Ionicons name="chevron-back" size={24} color={Colors[colorScheme ?? 'light'].text} />
      </TouchableOpacity>
      <Logo size={14} color={Colors[colorScheme ?? 'light'].selectedIcon} style={{ marginBottom: 50 }} />
      <View style={{ width: '100%', alignItems: 'center' }}>
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
          label='Password'
          placeholder='Enter your password'
          icon='lock-closed'
          type='password'
          inputStyle={{ width: '90%' }}
          value={password}
          onChangeText={setPassword}
          style={{ width: "90%", marginBottom: 25 }}
        />
        <InputArea
          label='Birth Date'
          placeholder='26/11/2002'
          icon='calendar'
          type='birthDate'
          format='mmddyyyy'
          inputStyle={{ width: '90%' }}
          value={birthDate}
          onChangeText={setBirthDate}
          style={{ width: "90%", marginBottom: 55 }}
        />
        <ActionButton
          title="Next"
          onPress={() => {
            console.log(password)
            console.log(birthDate)
            console.log(email)

          }}
          width={'90%'}
        />
      </View>
    </SafeAreaView>
  );
}