import { Colors } from '@/constants/Colors';
import React from 'react';
import { View, Image, StyleSheet, useColorScheme } from 'react-native';

interface ProfileIconProps {
    imageUrl: string;
    isSelected: boolean;
    size: number;
}

const ProfileIcon: React.FC<ProfileIconProps> = ({ imageUrl, isSelected, size }) => {
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
      <Image source={{ uri: imageUrl }} style={styles.image} />
    </View>
  );
};


export default ProfileIcon;
