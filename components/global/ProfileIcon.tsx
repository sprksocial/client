import { Colors } from '@/constants/Colors';
import { UserProps } from '@/types/Interfaces';
import React from 'react';
import { View, Image, StyleSheet, useColorScheme } from 'react-native';


const ProfileIcon: React.FC<{ userData: UserProps, isSelected: boolean, size: number }> = ({ userData, isSelected, size }) => {
  const colorScheme = useColorScheme();

  const styles = StyleSheet.create({
    container: {
      overflow: 'hidden',
      justifyContent: 'center',
      alignItems: 'center',
    },
    selectedBorder: {
      borderWidth: 2,
      borderColor: Colors[colorScheme ?? 'light'].tint,
      transitionDuration: '0.5s',
      transitionProperty: 'borderColor',
    },
    image: {
      width: '100%',
      height: '100%',
      resizeMode: 'cover',
    },
  });

  return (
    <View style={[
      styles.container,
      { width: size, height: size, borderRadius: size / 2 },
      isSelected && styles.selectedBorder
    ]}>
      <Image source={{ uri: userData.avatar }} style={styles.image} />
    </View>
  );
};


export default ProfileIcon;
