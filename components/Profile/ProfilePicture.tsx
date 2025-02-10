import { Colors } from '@/constants/Colors';
import { UserProps } from '@/types/Interfaces';
import React from 'react';
import { Image, StyleSheet, useColorScheme, View } from 'react-native';

const ProfilePicture: React.FC<{ userData: UserProps }> = ({ userData }) => {
  
    const colorScheme = useColorScheme();

const styles = StyleSheet.create({
  container: {
    height: 70,
    width: 70,
    borderRadius: 50,
    backgroundColor:  Colors[colorScheme ?? 'light'].background,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
    borderRadius: 50,
  },
});


  return (
    <View style={styles.container}>
      <Image source={{ uri: userData.image }} style={styles.image} />
    </View>
  );
};

export default ProfilePicture;
