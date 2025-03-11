import ActionButton from '@/components/global/ActionButton';
import InputArea from '@/components/global/InputArea';
import Logo from '@/components/global/Logo';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { pdsRegister } from '@/api/pdsAuth';
import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useCallback, useRef, useState, useMemo, useEffect } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, SafeAreaView, Dimensions, ActivityIndicator, Animated } from 'react-native';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { format } from 'date-fns';
import Reanimated, { withTiming, useAnimatedStyle, useSharedValue, withSequence, SlideInUp, SlideOutDown } from 'react-native-reanimated';

// Define the domain constant
const DOMAIN = '.sprk.so';

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
    handleInputContainer: {
      flexDirection: 'row',
      alignItems: 'center',
      width: '90%',
      marginBottom: 25,
    },
    handleDomain: {
      fontSize: 16,
      color: Colors[colorScheme ?? 'light'].textGray,
      paddingRight: 12,
      marginLeft: 5,
    },
    toastContainer: {
      position: 'absolute',
      top: 100,
      left: 20,
      right: 20,
      backgroundColor: 'rgba(255, 0, 0, 0.8)',
      padding: 15,
      borderRadius: 8,
      alignItems: 'center',
      zIndex: 1000,
    },
    toastText: {
      color: 'white',
      fontWeight: 'bold',
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
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [inviteCode, setInviteCode] = useState('');
  const [birthDate, setBirthDate] = useState<Date>(new Date());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showToast, setShowToast] = useState(false);

  // Error toast timing effect
  useEffect(() => {
    if (error) {
      setShowToast(true);
      const timer = setTimeout(() => {
        setShowToast(false);
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [error]);

  const handleDateChange = (event: DateTimePickerEvent, selectedDate: Date | undefined) => {
    if (selectedDate) {
      setBirthDate(selectedDate);
    }
  };

  const confirmDateSelection = () => {
    closeBottomSheet();
  };

  // Function to get the full handle with domain
  const getFullHandle = () => {
    return `${username}${DOMAIN}`;
  };

  const handleRegister = async () => {
    const trimmedEmail = email.trim();
    const trimmedUsername = username.trim();

    if (!trimmedEmail || !trimmedUsername || !password || !birthDate) {
      setError('Please fill in all required fields');
      return;
    }

    // Improved email validation with proper trimming
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(trimmedEmail)) {
      setError('Please enter a valid email address');
      return;
    }

    // Username validation (no dots, no spaces, alphanumeric only)
    const usernameRegex = /^[a-zA-Z0-9_-]+$/;
    if (!usernameRegex.test(trimmedUsername)) {
      setError('Username can only contain letters, numbers, underscores, and hyphens');
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

      // Get the full handle with domain and use it for registration
      const fullHandle = getFullHandle();
      
      // Call the pdsRegister function from our API
      await pdsRegister(trimmedEmail, fullHandle, password, inviteCode || undefined);

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
      
      {/* Animated Toast for Errors */}
      {showToast && (
        <Reanimated.View 
          style={styles.toastContainer}
          entering={SlideInUp}
          exiting={SlideOutDown}
        >
          <ThemedText style={styles.toastText}>{error}</ThemedText>
        </Reanimated.View>
      )}
      
      <View style={styles.formContainer}>
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
        
        {/* Custom username input with domain appended */}
        <View style={styles.handleInputContainer}>
          <InputArea
            label='Username'
            placeholder='Choose your username'
            icon='at'
            type='text'
            inputStyle={{ flex: 1, paddingRight: 0 }}
            value={username}
            onChangeText={setUsername}
            style={{ flex: 1 }}
          />
          <ThemedText style={styles.handleDomain}>{DOMAIN}</ThemedText>
        </View>
        
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