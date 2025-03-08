import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { pdsRegister } from '@/api/pdsAuth';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useCallback, useRef, useState, useMemo } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView, Dimensions, ActivityIndicator } from 'react-native';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { format } from 'date-fns';

export default function Register() {
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      width: '100%',
      position: 'relative',
    },
    formContainer: {
      width: '100%',
      alignItems: 'center',
      flex: 1,
      justifyContent: 'center',
    },
    backButton: {
      position: 'absolute',
      top: 80,
      left: 20,
      zIndex: 1,
    },
    logo: {
      marginTop: 80,
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
    datePickerButton: {
      flexDirection: 'row',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: Colors[colorScheme ?? 'light'].underlineColor,
      borderRadius: 8,
      paddingHorizontal: 12,
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      height: 50,
      width: '90%',
      marginBottom: 25,
    },
    datePickerIcon: {
      marginRight: 10,
    },
    datePickerText: {
      flex: 1,
      fontSize: 16,
      color: Colors[colorScheme ?? 'light'].text,
    },
    datePickerPlaceholder: {
      flex: 1,
      fontSize: 16,
      color: Colors[colorScheme ?? 'light'].textGray,
    },
    bottomSheetContent: {
      padding: 20,
      alignItems: 'center',
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      paddingBottom: 40,
    },
    bottomSheetButton: {
      padding: 15,
      backgroundColor: Colors[colorScheme ?? 'light'].tint,
      borderRadius: 8,
      alignItems: 'center',
      marginTop: 30,
      marginBottom: 30,
      width: '80%',
    },
    bottomSheetButtonText: {
      color: '#fff',
      fontWeight: 'bold',
      fontSize: 16,
    },
    bottomSheetBackground: {
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    bottomSheetHandle: {
      backgroundColor: Colors[colorScheme ?? 'light'].underlineColor,
      width: 40,
    },
    dateLabelText: {
      alignSelf: 'flex-start',
      marginLeft: '5%',
      marginBottom: 6,
    },
    datePickerTitle: {
      fontSize: 18,
      fontWeight: 'bold',
      marginBottom: 20,
    },
    chevronIcon: {
      marginLeft: 5,
    },
    inputStyle: {
      width: '90%',
    },
    passwordInputStyle: {
      width: '90%',
      marginBottom: 25,
    },
  });

  const bottomSheetRef = useRef<BottomSheet>(null);

  // Use fixed height for bottom sheet
  const snapPoints = useMemo(() => ['60%'], []);

  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);

  const openBottomSheet = useCallback(() => {
    bottomSheetRef.current?.expand();
  }, []);

  const closeBottomSheet = useCallback(() => {
    bottomSheetRef.current?.close();
  }, []);

  const [email, setEmail] = useState('');
  const [handle, setHandle] = useState('');
  const [password, setPassword] = useState('');
  const [inviteCode, setInviteCode] = useState('');
  const [birthDate, setBirthDate] = useState<Date>(new Date());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleDateChange = (event: DateTimePickerEvent, selectedDate: Date | undefined) => {
    if (selectedDate) {
      setBirthDate(selectedDate);
    }
  };

  const confirmDateSelection = () => {
    closeBottomSheet();
  };

  const handleRegister = async () => {
    if (!email || !handle || !password || !birthDate) {
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
      setError('Handle must be in format username.sprk.so');
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
        style={styles.backButton}>
        <Ionicons name="chevron-back" size={24} color={Colors[colorScheme ?? 'light'].text} />
      </TouchableOpacity>
      
      <Logo size={14} color={Colors[colorScheme ?? 'light'].selectedIcon} style={styles.logo} />
      
      <View style={styles.formContainer}>
        {error ? <ThemedText style={styles.errorText}>{error}</ThemedText> : null}
      
        <InputArea
          label='Email'
          placeholder='Enter your email'
          icon='mail'
          type='email'
          inputStyle={{ width: '100%' }}
          value={email}
          onChangeText={setEmail}
          style={styles.inputStyle}
        />
        
        <InputArea
          label='Handle'
          placeholder='username.sprk.so'
          icon='at'
          type='text'
          inputStyle={{ width: '100%' }}
          value={handle}
          onChangeText={setHandle}
          style={styles.inputStyle}
        />
        
        <InputArea
          label='Password'
          placeholder='Enter your password'
          icon='lock-closed'
          type='password'
          inputStyle={{ width: '90%' }}
          value={password}
          onChangeText={setPassword}
          style={styles.passwordInputStyle}
        />
        
        <InputArea
          label='Invite Code (Optional)'
          placeholder='Enter invite code if you have one'
          icon='key'
          type='text'
          inputStyle={{ width: '90%' }}
          value={inviteCode}
          onChangeText={setInviteCode}
          style={styles.inputStyle}
        />
        
        {/* Birth Date Picker Button */}
        <ThemedText type='description' style={styles.dateLabelText}>Birth Date</ThemedText>
        <TouchableOpacity 
          style={styles.datePickerButton}
          onPress={openBottomSheet}
        >
          <Ionicons
            name="calendar-outline"
            size={20}
            color={Colors[colorScheme ?? 'light'].icon}
            style={styles.datePickerIcon}
          />
          {birthDate ? (
            <ThemedText style={styles.datePickerText}>
              {format(birthDate, 'MMMM dd, yyyy')}
            </ThemedText>
          ) : (
            <ThemedText style={styles.datePickerPlaceholder}>
              Select your birth date
            </ThemedText>
          )}
          <Ionicons
            name="chevron-down"
            size={20}
            color={Colors[colorScheme ?? 'light'].icon}
            style={styles.chevronIcon}
          />
        </TouchableOpacity>
        
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
      
      {/* Bottom Sheet for Date Picker - outside of the form container */}
      <BottomSheet
        ref={bottomSheetRef}
        index={-1}
        snapPoints={snapPoints}
        onChange={handleSheetChanges}
        enablePanDownToClose
        backgroundStyle={styles.bottomSheetBackground}
        handleIndicatorStyle={styles.bottomSheetHandle}
      >
        <BottomSheetView style={styles.bottomSheetContent}>
          <ThemedText style={styles.datePickerTitle}>
            Select Your Birth Date
          </ThemedText>
          <DateTimePicker
            value={birthDate}
            mode="date"
            display="spinner"
            onChange={handleDateChange}
            maximumDate={new Date()}
          />
          <TouchableOpacity 
            style={styles.bottomSheetButton}
            onPress={confirmDateSelection}
          >
            <ThemedText style={styles.bottomSheetButtonText}>Done</ThemedText>
          </TouchableOpacity>
        </BottomSheetView>
      </BottomSheet>
    </SafeAreaView>
  );
}