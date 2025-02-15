// HomeScreen.tsx
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
import { PostProps } from '@/types/Interfaces';
import { fetchTrendingPosts } from '@/api/videoServices';

export default function HomeScreen() {
  const flatListRef = useRef<FlatList>(null);
  const [postData, setPostData] = useState<PostProps[]>([]);
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

  useEffect(() => {
    const loadVideos = async () => {
      const videos = await fetchTrendingPosts('video');
      setPostData(videos);
    };
    loadVideos();
  }, []);

  return (
    <ThemedView style={styles.root}>
      <VideoTop />
      <FlatList
        ref={flatListRef}
        data={postData}
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