import { Colors } from '@/constants/Colors';
import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator, useColorScheme } from 'react-native';

interface ActionButtonProps {
  title: string;
  onPress: () => void;
  type?: 'primary' | 'secondary' | 'outline' | 'disabled'; // Different button styles
  isLoading?: boolean; // Optional loading state
  width?: number; // Optional full-width button
}

const ActionButton: React.FC<ActionButtonProps> = ({
  title,
  onPress,
  type = 'primary',
  isLoading = false,
  width,
}) => {

  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    button: {
      paddingVertical: 12,
      paddingHorizontal: 20,
      borderRadius: 8,
      alignItems: 'center',
      justifyContent: 'center',
    },
    primary: {
      backgroundColor: Colors[colorScheme ?? 'light'].tint,
    },
    secondary: {
      backgroundColor: '#6c757d',
    },
    outline: {
      backgroundColor: 'transparent',
      borderWidth: 2,
      borderColor: Colors[colorScheme ?? 'light'].tint,
    },
    disabled: {
      backgroundColor: '#cccccc',
    },
    buttonText: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#ffffff',
    },
    outlineText: {
      color: Colors[colorScheme ?? 'light'].tint,
    },
  });
  
  return (
    <TouchableOpacity
      style={[
        styles.button,
        styles[type],
         { width: width },
      ]}
      onPress={onPress}
      disabled={type === 'disabled' || isLoading}
    >
      {isLoading ? (
        <ActivityIndicator color={type === 'outline' ? '#000' : '#fff'} />
      ) : (
        <Text style={[styles.buttonText, type === 'outline' && styles.outlineText]}>
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
};

export default ActionButton;
