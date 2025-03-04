import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator, useColorScheme, DimensionValue } from 'react-native';

interface ActionButtonProps {
  title: string;
  onPress: () => void;
  type?: 'primary' | 'secondary' | 'outline' | 'disabled';
  icon?: string;
  isLoading?: boolean;
  width?: string | number;
}

const ActionButton: React.FC<ActionButtonProps> = ({
  title,
  onPress,
  type = 'primary',
  isLoading = false,
  width,
  icon,
}) => {

  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    button: {
      paddingVertical: 12,
      paddingHorizontal: 20,
      borderRadius: 8,
      alignItems: 'center',
      justifyContent: 'center',
      flexDirection: 'row',
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
      color: Colors.dark.text,
    },
    outlineText: {
      color: Colors[colorScheme ?? 'light'].text,
    },
  });
  
  return (
    <TouchableOpacity
      style={[
        styles.button,
        styles[type],
         { width: width as DimensionValue },
      ]}
      onPress={onPress}
      disabled={type === 'disabled' || isLoading}
    >
      {icon && <Ionicons name={icon as any} size={25} color={Colors.dark.text} />}
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
