import React from 'react';
import { View, StyleSheet, TouchableOpacity, Image } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { SoundProps } from './SoundRowsCategory';

interface MusicDisplayProps {
  sound: SoundProps;
  onPress: (sound: SoundProps) => void;
}

const MusicDisplay: React.FC<MusicDisplayProps> = ({ sound, onPress }) => {
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress(sound)}
      activeOpacity={0.7}
    >
      <View style={styles.content}>
        <Image 
          source={{ uri: sound.coverImage }} 
          style={styles.image} 
          resizeMode="cover"
        />
        <View style={styles.textContainer}>
          <ThemedText 
            style={styles.title}
            numberOfLines={1}
          >
            {sound.title}
          </ThemedText>
          <ThemedText 
            style={styles.artist}
            numberOfLines={1}
          >
            {sound.artist}
          </ThemedText>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 6,
    marginVertical: 4,
    borderRadius: 40,
    backgroundColor: '#222222', // Match the exact dark color in reference
    alignSelf: 'flex-start', // Allow width to adjust to content
    overflow: 'hidden',
    minWidth: 180, // Minimum width to look good
    maxWidth: 280, // Maximum width to avoid extremely long pills
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingHorizontal: 14,
    height: 60, // Fixed height
  },
  image: {
    width: 36,
    height: 36,
    borderRadius: 18,
  },
  textContainer: {
    marginLeft: 14,
    paddingRight: 12,
    flex: 1, // Take remaining space
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'white',
  },
  artist: {
    fontSize: 14,
    color: '#AAAAAA',
    marginTop: 2,
  },
});

export default MusicDisplay; 