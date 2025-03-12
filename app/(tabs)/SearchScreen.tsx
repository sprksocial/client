import React, { useEffect, useState } from 'react';
import { SafeAreaView, ScrollView, StyleSheet, useColorScheme, View } from 'react-native';
import ContentWrapper from '@/components/global/ContentWrapper';
import SearchBar from '@/components/Search/SearchBar';
import FeaturedProfile from '@/components/Search/FeaturedProfile';
import VideoDisplay from '@/components/global/VideoDisplay';
import PlaceholderVideoDisplay from '@/components/Profile/PlaceholderVideoDisplay';
import { Colors } from '@/constants/Colors';
import { UserProps, PostProps } from '@/types/Interfaces';
import { fetchTrendingPosts } from '@/api/feedServices';
import { getProfile } from '@/api/profileServices';
import { useRouter } from 'expo-router';
import VideoRowCategory from '@/components/Search/VideoRowCategory';
import SoundRowsCategory, { SoundProps } from '@/components/Search/SoundRowsCategory';
import { trendingSounds } from '@/components/Search/mockSoundsData';
import { Ionicons, FontAwesome5, MaterialCommunityIcons } from '@expo/vector-icons';

// Pad posts so that the grid always has complete rows
function padPostsWithPlaceholders(
  posts: PostProps[]
): (PostProps & { isPlaceholder?: boolean })[] {
  const remainder = posts.length % 3;
  const placeholdersNeeded = remainder === 0 ? 0 : 3 - remainder;

  const placeholders: (PostProps & { isPlaceholder?: boolean })[] = Array(placeholdersNeeded)
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
  return [...posts, ...placeholders];
}

export default function SearchScreen() {
  const colorScheme = useColorScheme();
  const router = useRouter();
  const [videoData, setVideoData] = useState<PostProps[]>([]);
  const [featuredUser, setFeaturedUser] = useState<UserProps | null>(null);

  function handleOpenProfileFeed(postClicked: PostProps) {
    const index = videoData.findIndex((post) => post.uri === postClicked.uri);
    router.push({
      pathname: '../ProfileFeed',
      params: {
        videoData: JSON.stringify(videoData),
        initialIndex: index.toString(),
      },
    });
  }

  function handleSoundPress(sound: SoundProps) {
    console.log('Sound pressed:', sound.title);
    // Future implementation: play sound or navigate to sound details
  }

  useEffect(() => {
    const loadTrendingData = async () => {
      try {
        const posts = await fetchTrendingPosts('video');
        setVideoData(posts);
        if (posts.length > 0) {
          const did = posts[2]?.author?.did;
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

  const paddedVideoData = padPostsWithPlaceholders(videoData);

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
        <ScrollView
          contentContainerStyle={styles.scrollViewContent}
          showsVerticalScrollIndicator={false}>
          <SearchBar onSearch={() => {}} />
          {featuredUser && (
            <FeaturedProfile user={featuredUser} isFollowing={false} onFollow={() => {}} />
          )}
          <VideoRowCategory
            icon={<Ionicons name="flame" size={24} color={Colors[colorScheme ?? 'light'].text} />}
            title="Trending"
            videos={videoData}
            onVideoPress={handleOpenProfileFeed}
          />
          <SoundRowsCategory
            icon={<MaterialCommunityIcons name="music-circle" size={24} color={Colors[colorScheme ?? 'light'].text} />}
            title="Sounds"
            sounds={trendingSounds}
            onSoundPress={handleSoundPress}
          />
          <View style={styles.videoGrid}>
            {paddedVideoData.map((post, index) => {
              const key = post.uri || `fallback-${index}`;
              if (post.isPlaceholder) {
                return <PlaceholderVideoDisplay key={key} />;
              }
              return (
                <VideoDisplay
                  key={key}
                  videoSource={post}
                  onVideoPress={handleOpenProfileFeed}
                />
              );
            })}
          </View>
        </ScrollView>
      </ContentWrapper>
    </SafeAreaView>
  );
}
