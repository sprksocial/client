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
  Platform,
  Modal,
  Dimensions,
  SafeAreaView
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { ThemedText } from '../ThemedText';
import BottomSlider from './BottomSlider';
import ActionButton from './ActionButton';

interface BaseInputAreaProps {
  placeholder: string;
  value: string;
  onChangeText: (text: string) => void;
  icon?: string;
  label?: string;
  error?: string;
  disabled?: boolean;
  style?: ViewStyle;
  inputStyle?: TextStyle;
  maxLength?: number;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
}

interface NonBirthDateProps extends BaseInputAreaProps {
  type?: 'text' | 'email' | 'password' | 'username';
  format?: never;
}

interface BirthDateProps extends BaseInputAreaProps {
  type: 'birthDate';
  format: 'ddmmyy' | 'mmddyy' | 'ddmmyyyy' | 'mmddyyyy';
}

export type InputAreaProps = NonBirthDateProps | BirthDateProps;

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
  format,
}) => {
  const colorScheme = useColorScheme();
  const [secureTextEntry, setSecureTextEntry] = useState(type === 'password');
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [date, setDate] = useState(new Date());

  const getKeyboardType = (): KeyboardTypeOptions => {
    switch (type) {
      case 'email':
        return 'email-address';
      case 'username':
      case 'text':
        return 'default';
      case 'birthDate':
        return 'numeric';
      default:
        return 'default';
    }
  };

  const formatDate = (date: Date): string => {
    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const fullYear = date.getFullYear().toString();
    const year = fullYear.slice(2);

    switch (format) {
      case 'ddmmyy':
        return `${day}/${month}/${year}`;
      case 'mmddyy':
        return `${month}/${day}/${year}`;
      case 'ddmmyyyy':
        return `${day}/${month}/${fullYear}`;
      case 'mmddyyyy':
        return `${month}/${day}/${fullYear}`;
      default:
        return type === 'birthDate' ? `${day}/${month}/${fullYear}` : '';
    }
  };

  const handleDateChange = (event: any, selectedDate?: Date) => {
    const currentDate = selectedDate || date;

    if (Platform.OS === 'android') {
      setShowDatePicker(false);
    }

    setDate(currentDate);
    onChangeText(formatDate(currentDate));
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
    datePickerButton: {
      flex: 1,
      justifyContent: 'center',
      height: '40%',
      width: '90%',
    },
    modalContent: {
      width: '100%',
      height: '100%',
      position: 'absolute',
      bottom: 0,
      zIndex: 1,
    },
  });

  const renderDatePicker = () => {
    if (Platform.OS === 'ios') {
      return (
        showDatePicker &&
        <SafeAreaView style={styles.modalContent}>
          <View style={{
            position: 'absolute', 
            bottom: -100,
            left: 0,
            width: '100%', 
            height: Dimensions.get('screen').height / 3,
            backgroundColor: Colors[colorScheme ?? 'light'].background,
            justifyContent: 'center',
            alignItems: 'center',
            }}>
          <DateTimePicker
            value={date}
            mode="date"
            display="spinner"
            onChange={handleDateChange}
            maximumDate={new Date()}
          />
          <ActionButton
            title="Done"
            onPress={() => setShowDatePicker(false)}
            width={'100%'}
          />
          </View>
        </SafeAreaView>
      );
    }

    return showDatePicker && (
      <DateTimePicker
        value={date}
        mode="date"
        display="default"
        onChange={handleDateChange}
        maximumDate={new Date()}
      />
    );
  };

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

        {type === 'birthDate' ? (
          <TouchableOpacity
            style={styles.datePickerButton}
            onPress={() => !disabled && setShowDatePicker(true)}
            disabled={disabled}
          >
            <Text
              style={[
                styles.input,
                inputStyle,
                !value && { color: Colors[colorScheme ?? 'light'].textGray }
              ]}
            >
              {value || placeholder}
            </Text>
          </TouchableOpacity>
        ) : (
          <TextInput
            placeholder={placeholder}
            placeholderTextColor={Colors[colorScheme ?? 'light'].textGray}
            value={value}
            onChangeText={onChangeText}
            secureTextEntry={secureTextEntry && type === 'password'}
            keyboardType={getKeyboardType()}
            editable={!disabled}
            autoCapitalize={autoCapitalize}
            autoComplete={type === 'password' || (type as string) === 'birthDate' ? 'off' : 'name'}
            autoCorrect={false}
            maxLength={maxLength}
            style={[styles.input, inputStyle]}
          />
        )}

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

        {type === 'birthDate' && (
          <TouchableOpacity
            onPress={() => !disabled && setShowDatePicker(true)}
            style={styles.passwordIcon}
            disabled={disabled}
          >
            <Ionicons
              name="calendar-outline"
              size={20}
              color={Colors[colorScheme ?? 'light'].icon}
            />
          </TouchableOpacity>
        )}
      </View>

      {error && <Text style={styles.errorText}>{error}</Text>}
      {type === 'birthDate' && (
        <View style={{
        }}>
          {renderDatePicker()}
        </View>
      )}
    </View>
  );
};

export default InputArea;