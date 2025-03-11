import React from 'react';
import { View, StyleSheet } from 'react-native';
import VideoDisplay from '@/components/global/VideoDisplay';
import PlaceholderVideoDisplay from '@/components/Profile/PlaceholderVideoDisplay';
import { PostProps } from '@/types/Interfaces';

interface ProfileVideoGridProps {
  videos: (PostProps & { isPlaceholder?: boolean })[];
  onVideoPress: (post: PostProps) => void;
}

const ProfileVideoGrid = ({ videos, onVideoPress }: ProfileVideoGridProps) => {
  return (
    <View style={styles.videoGrid}>
      {videos.map((item, index) => {
        const key = item.uri ? item.uri : `fallback-${index}`;

        if (item.isPlaceholder) {
          return <PlaceholderVideoDisplay key={key} />;
        }
        
        return (
          <VideoDisplay
            key={key}
            videoSource={item}
            onVideoPress={onVideoPress}
          />
        );
      })}
    </View>
  );
};

// Utility function to ensure the grid is filled with placeholders if needed
export function padVideosWithPlaceholders(
  videos: (PostProps & { isPlaceholder?: boolean })[]
): (PostProps & { isPlaceholder?: boolean })[] {
  const remainder = videos.length % 3;
  const placeholdersNeeded = remainder === 0 ? 0 : 3 - remainder;

  const placeholders: (PostProps & { isPlaceholder?: boolean })[] = Array(
    placeholdersNeeded
  )
    .fill(null)
    .map((_, i) => ({
      uri: `placeholder-${i}`,
      cid: '',
      author: {
        did: '',
        handle: '',
        displayName: '',
        avatar: '',
        banner: '',
      },
      record: {
        $type: 'app.bsky.feed.post',
        createdAt: '',
        text: '',
        langs: [],
      },
      replyCount: 0,
      repostCount: 0,
      likeCount: 0,
      quoteCount: 0,
      indexedAt: '',
      labels: [],
      isPlaceholder: true,
    }));

  return [...videos, ...placeholders];
}

const styles = StyleSheet.create({
  videoGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
});

export default ProfileVideoGrid; 