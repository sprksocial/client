import React, { useEffect, useRef, useState } from 'react';
import {
  StyleSheet,
  FlatList,
  View,
  Dimensions,
} from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import VideoScreen from '@/components/Video/VideoScreen';
import VideoTop from '@/components/Video/VideoTop';

import { VideoProps } from '@/types/Interfaces';

export default function HomeScreen() {
  const flatListRef = useRef<FlatList>(null);
  const [videoData, setVideoData] = useState<VideoProps[]>([]);
  const [currentVisibleIndex, setCurrentVisibleIndex] = useState(0);

  const onViewRef = useRef(({ viewableItems }: any) => {
    if (viewableItems.length > 0) {
      const index = viewableItems[0].index;
      if (index !== null && index !== undefined) {
        setCurrentVisibleIndex(index);
      }
    }
  });

  const viewConfigRef = useRef({
    viewAreaCoveragePercentThreshold: 95,
  });

  const { height: windowHeight } = Dimensions.get('window');
  const TAB_BAR_HEIGHT = windowHeight * 0.1;
  const availableHeight = windowHeight - TAB_BAR_HEIGHT;

  const getItemLayout = (_: any, index: number) => ({
    length: availableHeight,
    offset: availableHeight * index,
    index,
  });

  const fetchTrendingVideos = async (): Promise<VideoProps[]> => {
    try {
      const res = await fetch(
        'https://public.api.bsky.app/xrpc/app.bsky.feed.getFeed?feed=at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot&limit=100'
      );
      const data = await res.json();
      if (!data || !data.feed) return [];

      const extractHashtags = (text: string): string[] => {
        if (!text) return [];
        const match = text.match(/#[\w]+/g);
        return match ? match.map(tag => tag.replace('#', '')) : [];
      };

      const mappedVideos: VideoProps[] = data.feed
        .map((item: any, idx: number) => {
          const post = item?.post;
          const record = post?.record;
          const author = post?.author;
          const embed = post?.embed;

          if (!post || !record || !author) {
            return null;
          }

          if (!embed || embed.$type !== 'app.bsky.embed.video#view') {
            return null;
          }

          const likeCount = post.likeCount || 0;
          const shareCount = post.repostCount || 0;
          const textContent = record.text || '';

          const videoSource = embed.playlist || '';
          const thumbnail   = embed.thumbnail || '';

          const sparkVideo: VideoProps = {
            id: post.cid || `bluesky-video-${idx}`,
            videoSource,
            thumbnail,
            creator: {
              id: author.did,
              name: author.displayName || author.handle,
              image: author.avatar,
              handler: author.handle,
              bio: author.bio,
              did: author.did,
            },
            likes: {
              amount: likeCount,
              onLike: () => console.log(`Liked video ${post.cid}`),
            },
            views: 0,
            shares: shareCount,
            description: {
              content: textContent,
              hashtags: {
                content: extractHashtags(textContent),
              },
            },
            comments: [],
            isActive: false, // default value; will be overridden in renderItem
          };

          return sparkVideo;
        })
        .filter((v: VideoProps | null): v is VideoProps => v !== null) as VideoProps[];

      return mappedVideos;
    } catch (error) {
      console.log('Erro ao buscar feed do Bluesky:', error);
      return [];
    }
  };

  useEffect(() => {
    const loadVideos = async () => {
      const videos = await fetchTrendingVideos();
      setVideoData(videos);
    };
    loadVideos();
  }, []);

  return (
    <ThemedView style={styles.root}>
      <VideoTop />
      <FlatList
        ref={flatListRef}
        data={videoData}
        keyExtractor={(item, index) => `${item.id}-${index}`}
        renderItem={({ item, index }) => {
          const isActive = index === currentVisibleIndex;
          return (
            <View style={[styles.videoContainer, { height: availableHeight }]}>
              <VideoScreen videoData={{ ...item, isActive }} />
            </View>
          );
        }}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        onViewableItemsChanged={onViewRef.current}
        viewabilityConfig={viewConfigRef.current}
        decelerationRate="fast"
        initialNumToRender={3}
        maxToRenderPerBatch={2}
        windowSize={3}
        removeClippedSubviews
        scrollEventThrottle={16}
        style={styles.flatList}
        contentContainerStyle={styles.flatListContent}
        getItemLayout={getItemLayout}
      />
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#000',
  },
  flatList: {
    flex: 1,
  },
  flatListContent: {
    paddingBottom: 0,
  },
  videoContainer: {
    width: '100%',
    backgroundColor: '#000',
    justifyContent: 'center',
    alignItems: 'center',
  },
});