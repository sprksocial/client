import React, { useEffect, useState } from 'react';
import { SafeAreaView, ScrollView, StyleSheet, useColorScheme, View } from 'react-native';
import ContentWrapper from '@/components/global/ContentWrapper';
import SearchBar from '@/components/Search/SearchBar';
import FeaturedProfile from '@/components/Search/FeaturedProfile';
import VideoDisplay from '@/components/Profile/VideoDisplay';
import PlaceholderVideoDisplay from '@/components/Profile/PlaceholderVideoDisplay';
import { Colors } from '@/constants/Colors';
import { UserProps, VideoProps } from '@/types/Interfaces';
import { fetchTrendingVideos } from '@/api/videoServices';
import { getProfile } from '@/api/profileServices';
import { useRouter } from 'expo-router';

function padVideosWithPlaceholders(videos: VideoProps[]): (VideoProps & { isPlaceholder?: boolean })[] {
  const remainder = videos.length % 3;
  const placeholdersNeeded = remainder === 0 ? 0 : 3 - remainder;
  const placeholders = Array(placeholdersNeeded).fill(null).map((_, i) => ({
    id: `placeholder-${i}`,
    isPlaceholder: true,
  }));
  return [...videos, ...placeholders];
}

export default function SearchScreen() {
  const colorScheme = useColorScheme();
  const router = useRouter();
  const [videoData, setVideoData] = useState<VideoProps[]>([]);
  const [featuredUser, setFeaturedUser] = useState<UserProps | null>(null);

  function handleOpenProfileFeed(videoClicked: VideoProps) {
    const index = videoData.findIndex((video) => video.id === videoClicked.id);
    router.push({
      pathname: '../ProfileFeed',
      params: {
        videoData: JSON.stringify(videoData),
        initialIndex: index.toString(),
      },
    });
  }

  useEffect(() => {
    const loadTrendingData = async () => {
      try {
        const videos = await fetchTrendingVideos();
        setVideoData(videos);
        if (videos.length > 0) {
          const did = videos[0]?.creator?.did;
          if (did) {
            const profileData = await getProfile(did);
            if (profileData) {
              setFeaturedUser({
                id: profileData.did,
                did: profileData.did,
                displayName: profileData.displayName,
                handle: profileData.handle,
                description: profileData.description,
                avatar: profileData.avatar || '',
                banner: profileData.banner || '',
                followersCount: profileData.followersCount,
                followsCount: profileData.followsCount,
                likes: 0,
                views: 0,
                videos,
                postsCount: profileData.postsCount,
                associated: profileData.associated,
                joinedViaStarterPack: profileData.joinedViaStarterPack,
                indexedAt: profileData.indexedAt,
                createdAt: profileData.createdAt,
                viewer: profileData.viewer,
                labels: profileData.labels,
                pinnedPost: profileData.pinnedPost,
              });
            }
          }
        }
      } catch (err) {
        console.error(err);
      }
    };
    loadTrendingData();
  }, []);

  const paddedVideoData = padVideosWithPlaceholders(videoData);

  const styles = StyleSheet.create({
    container: {
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      height: '100%',
      alignContent: 'center',
      justifyContent: 'center',
    },
    scrollViewContent: {
      flexGrow: 1,
      paddingBottom: 20,
    },
    videoGrid: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      justifyContent: 'center',
    },
  });

  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView contentContainerStyle={styles.scrollViewContent} showsVerticalScrollIndicator={false}>
          <SearchBar onSearch={() => {}} />
          {featuredUser && <FeaturedProfile user={featuredUser} isFollowing={false} onFollow={() => {}} />}
          <View style={styles.videoGrid}>
            {paddedVideoData.map((video) => {
              if (video.isPlaceholder) {
                return <PlaceholderVideoDisplay key={video.id} />;
              }
              return <VideoDisplay key={video.id} videoSource={video} onVideoPress={handleOpenProfileFeed} />;
            })}
          </View>
        </ScrollView>
      </ContentWrapper>
    </SafeAreaView>
  );
}