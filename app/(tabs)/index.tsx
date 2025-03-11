import React, { useEffect, useRef, useState } from 'react';
import {
  StyleSheet,
  FlatList,
  View,
  Dimensions,
  Platform,
} from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import VideoScreen from '@/components/Video/VideoScreen';
import VideoTop from '@/components/Video/VideoTop';
import ImageScreen from '@/components/Image/ImageScreen';
import { PostProps } from '@/types/Interfaces';
import { fetchTrendingPosts } from '@/api/feedServices';
import { useBottomTabBarHeight } from '@react-navigation/bottom-tabs';

export default function HomeScreen() {
  const flatListRef = useRef<FlatList<PostProps>>(null);
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
  const TAB_BAR_HEIGHT = useBottomTabBarHeight();
  // Calculate available height properly for both platforms
  const availableHeight = windowHeight - TAB_BAR_HEIGHT;

  const shuffleArray = (array: any[]) => {
    return array.sort(() => Math.random() - 0.5);
  };

  useEffect(() => {
    const loadContent = async () => {
      try {
        const videoPosts = await fetchTrendingPosts('video');
        const imagePosts = await fetchTrendingPosts('image');
        const mergedData = shuffleArray([...videoPosts, ...imagePosts]);
        setPostData(mergedData);
      } catch (error) {
        console.error('Error fetching posts:', error);
      }
    };

    loadContent();
  }, []);

  return (
    <ThemedView style={styles.container}>
      <VideoTop />
      <FlatList
        ref={flatListRef}
        data={postData}
        keyExtractor={(item, index) => `${item.cid}-${index}`}
        renderItem={({ item, index }) => {
          const isActive = index === currentVisibleIndex;
          const embedType = item.embed?.$type || '';

          return (
            <View style={[styles.itemContainer, { height: availableHeight }]}>
              {embedType === 'app.bsky.embed.video' ||
              embedType === 'app.bsky.embed.video#view' ? (
                <VideoScreen videoData={{ ...item, isActive }} />
              ) : embedType === 'app.bsky.embed.images' ||
                embedType === 'app.bsky.embed.images#view' ? (
                <ImageScreen imageData={item} />
              ) : null}
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
        removeClippedSubviews
        scrollEventThrottle={16}
        contentContainerStyle={Platform.OS === 'android' ? { paddingBottom: TAB_BAR_HEIGHT } : undefined}
        style={styles.flatList}
      />
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  flatList: {
    backgroundColor: 'black',
  },
  itemContainer: {
    width: '100%',
  }
});
