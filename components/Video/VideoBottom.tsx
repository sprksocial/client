import React, { useState, useRef } from 'react';
import { View, StyleSheet, TouchableOpacity, useColorScheme, Text } from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { VideoBottomProps } from '@/types/Interfaces';

const VideoBottom: React.FC<VideoBottomProps> = ({ videoData }) => {
  const colorScheme = useColorScheme();
  const [expanded, setExpanded] = useState(false);
  const [textTooLong, setTextTooLong] = useState(false);

  // Hashtag extractor: supports one or more '#' characters.
  const hashtagExtractor = (text: string) => {
    const regex = /#+[a-zA-Z0-9_]+/g;
    const hashtags = text.match(regex);
    return hashtags || [];
  };

  const textContent = videoData.record?.text || '';
  // Remove hashtags from the text so they don't appear twice.
  const cleanedText = textContent.replace(/(#+[a-zA-Z0-9_]+\s*)/g, '').trim();
  const hashtags = hashtagExtractor(textContent);
  const MAX_HASHTAGS_COLLAPSED = 3;

  const handleTextLayout = (e: any) => {
    // Check if the text has been truncated by counting lines
    if (e.nativeEvent.lines && e.nativeEvent.lines.length > 2) {
      setTextTooLong(true);
    } else {
      setTextTooLong(false);
    }
  };

  const toggleExpand = () => {
    setExpanded(!expanded);
  };

  const styles = StyleSheet.create({
    container: {
      borderRadius: 10,
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
    readMoreText: {
      color: '#888',
      fontSize: 12,
      marginTop: 4,
    },
    hashtagsContainer: {
      marginTop: 6,
    },
    hashtags: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      gap: 4,
    },
    hashtagText: {
      color: '#fff',
      backgroundColor: '#00000050',
      paddingVertical: 1,
      paddingHorizontal: 8,
      borderRadius: 50,
      marginRight: 4,
      marginBottom: 4,
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
      <ThemedText
        lightColor={Colors.dark.text}
        darkColor={Colors.dark.text}
        style={styles.userInfo}
      >
        @{videoData.author?.handle || 'unknown'}
        <TouchableOpacity style={styles.followButton}>
          <ThemedText type="subtitle" style={{ color: "#fff" }}>
            Follow
          </ThemedText>
        </TouchableOpacity>
      </ThemedText>
      <TouchableOpacity onPress={toggleExpand}>
        <ThemedText
          type="description"
          lightColor={Colors.dark.text}
          darkColor={Colors.dark.text}
          style={styles.description}
          numberOfLines={!expanded ? 2 : undefined}
          ellipsizeMode="tail"
          onTextLayout={handleTextLayout}
        >
          {cleanedText}
        </ThemedText>
        
        {/* Only show hashtags when expanded or when there's enough space */}
        {hashtags.length > 0 && (expanded || !textTooLong) && (
          <View style={styles.hashtagsContainer}>
            <View style={styles.hashtags}>
              {(expanded || hashtags.length <= MAX_HASHTAGS_COLLAPSED
                ? hashtags
                : hashtags.slice(0, MAX_HASHTAGS_COLLAPSED)
              ).map((hashtag, index) => (
                <ThemedText key={index} type="description" style={styles.hashtagText}>
                  {hashtag}
                </ThemedText>
              ))}
            </View>
          </View>
        )}
        
        {/* Only show Read More/Less button when text is actually too long */}
        {textTooLong && (
          <ThemedText
            type="description"
            lightColor={Colors.dark.text}
            darkColor={Colors.dark.text}
            style={styles.readMoreText}
          >
            {!expanded ? 'Read More' : 'Read Less'}
          </ThemedText>
        )}
      </TouchableOpacity>
    </View>
  );
};

export default VideoBottom;