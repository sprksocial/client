import React from 'react';
import { View, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import VideoDisplay from '@/components/global/VideoDisplay';
import { PostProps } from '@/types/Interfaces';

interface VideoRowCategoryProps {
  icon: React.ReactNode;
  title: string;
  videos: PostProps[];
  onVideoPress: (post: PostProps) => void;
}

const VideoRowCategory: React.FC<VideoRowCategoryProps> = ({
  icon,
  title,
  videos,
  onVideoPress,
}) => {
  const handleViewAll = () => {
    console.log(`View all clicked for category: ${title}`);
  };

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
      
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {videos.map((video, index) => (
          <VideoDisplay
            key={video.uri || index}
            videoSource={video}
            onVideoPress={onVideoPress}
            containerStyle={styles.videoCard}
          />
        ))}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 16,
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
  scrollContent: {
    paddingLeft: 16,
    paddingRight: 8,
  },
  videoCard: {
    width: 150,
    height: 240,
    marginRight: 12,
    borderRadius: 12,
  },
});

export default VideoRowCategory;
