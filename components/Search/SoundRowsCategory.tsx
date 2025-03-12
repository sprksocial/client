import React from 'react';
import { View, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import MusicDisplay from './MusicDisplay';

// Interface for sound data
export interface SoundProps {
  id: string;
  title: string;
  artist: string;
  album: string;
  coverImage: string;
  plays: number;
}

interface SoundRowsCategoryProps {
  icon: React.ReactNode;
  title: string;
  sounds: SoundProps[];
  onSoundPress: (sound: SoundProps) => void;
}

const SoundRowsCategory: React.FC<SoundRowsCategoryProps> = ({
  icon,
  title,
  sounds,
  onSoundPress,
}) => {
  const handleViewAll = () => {
    console.log(`View all clicked for category: ${title}`);
  };

  // Split sounds array into two roughly equal parts for two rows
  const firstRowSounds = sounds.slice(0, Math.ceil(sounds.length / 2));
  const secondRowSounds = sounds.slice(Math.ceil(sounds.length / 2));

  return (
    <View style={styles.container}>
      <View style={styles.headerContainer}>
        <View style={styles.titleContainer}>
          {icon}
          <ThemedText style={styles.title} type="title">
            {title}
          </ThemedText>
        </View>
        <TouchableOpacity onPress={handleViewAll}>
          <ThemedText style={styles.viewAll} type="subtitle">
            view all
          </ThemedText>
        </TouchableOpacity>
      </View>
      
      {/* First row */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.soundsContainer}
        decelerationRate="fast"
      >
        {firstRowSounds.map((sound) => (
          <MusicDisplay 
            key={sound.id}
            sound={sound}
            onPress={onSoundPress}
          />
        ))}
      </ScrollView>

      {/* Second row */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.soundsContainer}
        decelerationRate="fast"
      >
        {secondRowSounds.map((sound) => (
          <MusicDisplay 
            key={sound.id}
            sound={sound}
            onPress={onSoundPress}
          />
        ))}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 20,
    width: '100%',
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
    paddingHorizontal: 16,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginLeft: 8,
  },
  viewAll: {
    fontSize: 14,
    color: '#666',
  },
  soundsContainer: {
    paddingLeft: 16,
    paddingRight: 16,
    paddingVertical: 6,
    flexDirection: 'row',
    alignItems: 'center',
  }
});

export default SoundRowsCategory; 