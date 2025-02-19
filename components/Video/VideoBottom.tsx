import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, useColorScheme } from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { VideoBottomProps } from '@/types/Interfaces';

const VideoBottom: React.FC<VideoBottomProps> = ({ videoData }) => {
  const colorScheme = useColorScheme();

  // extract hashtags from the text
  const hashtagExtractor = (text: string) => {
    const regex = /#[a-zA-Z0-9_]+/g;
    const hashtags = text.match(regex);
    return hashtags || [];
  };

  const hashtags = hashtagExtractor(videoData.record?.text || ''); // extract hashtags from the text
  
  const styles = StyleSheet.create({
    container: {
      padding: 10,
      borderRadius: 10,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-start',
      alignItems: 'flex-start',
      width: '85%',
    },
    userInfo: {
      fontWeight: 'bold',
      fontSize: 16,
      marginBottom: 4,
      alignItems: 'center',
      justifyContent: 'center',
      elevation: 3,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 0 },
      shadowOpacity: 0.2,
    },
    description: {
      fontSize: 14,
      marginBottom: 4,
    },
    hashtags: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      gap: 4,
      marginTop: 6,
    },
    hashtagText: {
      color: '#fff',
      backgroundColor: '#00000050',
      paddingVertical: 1,
      paddingHorizontal: 8,
      borderRadius: 50,
      display: 'flex',
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
    },
    followButton: {
      backgroundColor: '#ffffff40',
      paddingVertical: 2,
      paddingHorizontal: 8,
      borderRadius: 6,
      marginLeft: 10,
      display: 'none',
    },
  });
  return (
    <View style={styles.container}>
      <ThemedText lightColor={Colors.dark.text} darkColor={Colors.dark.text} style={styles.userInfo}>
        {videoData.author?.displayName || 'Unknown'} • @{videoData.author?.handle || 'unknown'}
        <TouchableOpacity style={styles.followButton}>
          <ThemedText type='subtitle' style={{color: "#fff"}}>Follow</ThemedText>
        </TouchableOpacity>
      </ThemedText>
      <ThemedText type="description" lightColor={Colors.dark.text} darkColor={Colors.dark.text}>{videoData.record?.text || ''}</ThemedText>
      <View style={styles.hashtags}>
        {hashtags.map((hashtag, index) => (
          <ThemedText type="description" key={index} style={styles.hashtagText}>#{hashtag} </ThemedText>
        ))}
      </View>
    </View>
  );
};



export default VideoBottom;
