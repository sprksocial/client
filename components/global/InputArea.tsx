import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import React, { useState } from 'react';
import {
  View,
  TextInput,
  StyleSheet,
  Text,
  TouchableOpacity,
  useColorScheme,
  ViewStyle,
  TextStyle,
  KeyboardTypeOptions,
} from 'react-native';
import { ThemedText } from '../ThemedText';

interface InputAreaProps {
  placeholder: string;
  value: string;
  onChangeText: (text: string) => void;
  type?: 'text' | 'email' | 'password' | 'username';
  icon?: string;
  label?: string;
  error?: string;
  disabled?: boolean;
  style?: ViewStyle;
  inputStyle?: TextStyle;
  maxLength?: number;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
}

const InputArea: React.FC<InputAreaProps> = ({
  placeholder,
  value,
  onChangeText,
  type = 'text',
  icon,
  label,
  error,
  disabled = false,
  style,
  inputStyle,
  maxLength,
  autoCapitalize = 'none',
}) => {
  const colorScheme = useColorScheme();
  const [secureTextEntry, setSecureTextEntry] = useState(type === 'password');

  const getKeyboardType = (): KeyboardTypeOptions => {
    switch (type) {
      case 'email':
        return 'email-address';
      case 'username':
      case 'text':
        return 'default';
      default:
        return 'default';
    }
  };

  const styles = StyleSheet.create({
    container: {
      marginBottom: 16,
    },
    labelText: {
      fontSize: 14,
      fontWeight: '600',
      marginBottom: 6,
      color: Colors[colorScheme ?? 'light'].text,
    },
    inputContainer: {
      flexDirection: 'row',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: error
        ? Colors[colorScheme ?? 'light'].error
        : Colors[colorScheme ?? 'light'].underlineColor,
      borderRadius: 8,
      paddingHorizontal: 12,
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      height: 50,
    },
    icon: {
      marginRight: 10,
    },
    input: {
      flex: 1,
      color: Colors[colorScheme ?? 'light'].text,
      fontSize: 16,
      height: '100%',
    },
    errorText: {
      fontSize: 12,
      color: Colors[colorScheme ?? 'light'].error,
      marginTop: 4,
    },
    disabledInput: {
      opacity: 0.5,
    },
    passwordIcon: {
      padding: 4,
    },
  });

  return (
    <View style={[styles.container, style]}>
      {label && <ThemedText type='description'>{label}</ThemedText>}

      <View style={[styles.inputContainer, disabled && styles.disabledInput]}>
        {icon && (
          <Ionicons
            name={icon as any}
            size={20}
            color={Colors[colorScheme ?? 'light'].icon}
            style={styles.icon}
          />
        )}

        <TextInput
          placeholder={placeholder}
          placeholderTextColor={Colors[colorScheme ?? 'light'].textGray}
          value={value}
          onChangeText={onChangeText}
          secureTextEntry={secureTextEntry && type === 'password'}
          keyboardType={getKeyboardType()}
          editable={!disabled}
          autoCapitalize={autoCapitalize}
          autoComplete={type === 'password' ? 'off' : 'name'}
          autoCorrect={false}
          maxLength={maxLength}
          style={[styles.input, inputStyle]}
        />

        {type === 'password' && (
          <TouchableOpacity
            onPress={() => setSecureTextEntry(!secureTextEntry)}
            style={styles.passwordIcon}
          > 
            <Ionicons
              name={secureTextEntry ? 'eye-outline' : 'eye-off-outline'}
              size={20}
              color={Colors[colorScheme ?? 'light'].icon}
            />
          </TouchableOpacity>
        )}
      </View>

      {error && <Text style={styles.errorText}>{error}</Text>}
    </View>
  );
};

export default InputArea;