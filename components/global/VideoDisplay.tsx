import React from 'react';
import {
  TouchableOpacity,
  Image,
  StyleSheet,
  View,
  useColorScheme,
} from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { PostProps } from '@/types/Interfaces';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '@/constants/Colors';

interface VideoDisplayProps {
  videoSource: PostProps;
  onVideoPress: (post: PostProps) => void;
}

const VideoDisplay: React.FC<VideoDisplayProps> = ({
  videoSource,
  onVideoPress,
}) => {
  const colorScheme = useColorScheme();

  const handleVideoPress = () => {
    onVideoPress(videoSource);
  };

  const styles = StyleSheet.create({
    container: {
      width: '32%',
      aspectRatio: 12 / 17,
      borderRadius: 2,
      overflow: 'hidden',
      marginHorizontal: 1,
      marginVertical: 1,
      backgroundColor: '#000',
    },
    thumbnail: {
      width: '100%',
      height: '100%',
      resizeMode: 'cover',
    },
    overlay: {
      position: 'absolute',
      bottom: 0,
      width: '100%',
      padding: 8,
      backgroundColor: 'rgba(0, 0, 0, 0.5)',
    },
    viewCount: {
      fontSize: 16,
      color: Colors.dark.text,
      fontWeight: 'bold',
      textAlign: 'right',
      alignItems: 'center',
      justifyContent: 'flex-end',
      flexDirection: 'row',
    },
    viewCountText: {
      color: Colors.dark.text,
    },
    icon: {
      marginHorizontal: 5,
    },
  });

  const thumbnailUri = videoSource.embed?.thumbnail || '';

  return (
    <TouchableOpacity style={styles.container} onPress={handleVideoPress}>
      {thumbnailUri ? (
        <Image source={{ uri: thumbnailUri }} style={styles.thumbnail} />
      ) : null}
      <View style={styles.overlay}>
        <View style={styles.viewCount}>
          <Ionicons style={styles.icon} name="eye" size={16} color="white" />
          <ThemedText style={styles.viewCountText} type="comment">
            {videoSource.likeCount}
          </ThemedText>
        </View>
      </View>
    </TouchableOpacity>
  );
};

export default VideoDisplay;
