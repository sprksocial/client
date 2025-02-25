// ProfileFeed.tsx
import React, { useEffect, useRef, useState } from 'react';
import {
  StyleSheet,
  FlatList,
  View,
  Dimensions,
  TouchableOpacity,
} from 'react-native';
import { ThemedView } from '@/components/ThemedView';
import VideoScreen from '@/components/Video/VideoScreen';
import { PostProps } from '@/types/Interfaces';
import { router, Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useRoute } from '@react-navigation/native';

export default function ProfileFeed() {
  const flatListRef = useRef<FlatList>(null);
  const [postData, setPostData] = useState<PostProps[]>([]);
  const [currentVisibleIndex, setCurrentVisibleIndex] = useState(0);

  const route = useRoute();
  // Expect videoData as a JSON string and initialIndex as a string.
  const params = route.params as { videoData?: string; initialIndex?: string };

  // Parse initial index from params
  const initialIndex = parseInt(params.initialIndex ?? "0", 10) || 0;

  // Use the passed videoData from the router parameter instead of fetching trending posts.
  useEffect(() => {
    if (params.videoData) {
      try {
        const videos = JSON.parse(params.videoData) as PostProps[];
        setPostData(videos);
      } catch (error) {
        console.error("Error parsing videoData:", error);
      }
    }
  }, [params.videoData]);

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

  const { height: windowHeight } = Dimensions.get('screen');
  const TAB_BAR_HEIGHT = 0;
  const availableHeight = windowHeight - TAB_BAR_HEIGHT;

  const getItemLayout = (_: any, index: number) => ({
    length: availableHeight,
    offset: availableHeight * index,
    index,
  });

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <ThemedView style={styles.root}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={{ position: 'absolute', top: 50, left: 20, zIndex: 1 }}>
          <Ionicons name="chevron-back" size={24} color="#fff" />
        </TouchableOpacity>
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
          initialScrollIndex={initialIndex}
        />
      </ThemedView>
    </>
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