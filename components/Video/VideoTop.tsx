import React from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity } from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';

const VideoTop: React.FC = () => {
  const colorScheme = useColorScheme();

const styles = StyleSheet.create({
    container: {
      alignItems: 'center',
      justifyContent: 'center',
      position: 'absolute',
      width: '100%',
        top: '9%',
        zIndex: 1,
    },
    text: {
      fontWeight: 'bold',
      fontSize: 20,
      elevation: 1,
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
    },
  });

  
  return (
    <View style={styles.container}>
        <TouchableOpacity>
      <ThemedText type='defaultBold' darkColor={Colors.dark.text} lightColor={Colors.dark.text} style={styles.text}>For You</ThemedText>
        </TouchableOpacity>
    </View>
  );
};

export default VideoTop;
