import React, { useEffect, useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  useColorScheme,
  View,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import ContentWrapper from '@/components/global/ContentWrapper';
import { Colors } from '@/constants/Colors';
import ProfilePicture from '@/components/Profile/ProfilePicture';
import ProfileInfo from '@/components/Profile/ProfileInfo';
import ActionButton from '@/components/global/ActionButton';
import VideoDisplay from '@/components/global/VideoDisplay';
import PlaceholderVideoDisplay from '@/components/Profile/PlaceholderVideoDisplay';
import { did } from '@/constants/MockData';
import { UserProps, PostProps } from '@/types/Interfaces';
import { useRouter } from 'expo-router';
import { getProfile, getProfileMedia } from '@/api/profileServices';

function padVideosWithPlaceholders(
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


export default function ProfileScreen() {
  const colorScheme = useColorScheme();
  const route = useRouter();

  const [userData, setUserData] = useState<UserProps | null>(null);
  const [videoPosts, setVideoPosts] = useState<PostProps[]>([]);

  useEffect(() => {
    const loadProfileData = async () => {
      try {
        const profileData = await getProfile(did);
        if (profileData) {
          setUserData({
            id: profileData.did,
            did: profileData.did,
            displayName: profileData.displayName,
            handle: profileData.handle,
            description: profileData.description,
            avatar: profileData.avatar || '',
            banner: profileData.banner || '',
            followersCount: profileData.followersCount,
            followsCount: profileData.followsCount,
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
      } catch (error) {
        console.error('Error loading profile:', error);
      }
    };

    const loadVideoPosts = async () => {
      try {
        const mediaPosts = await getProfileMedia(did, 'video');
        const posts = mediaPosts.map((item: { post: PostProps }) => item.post as PostProps);
        setVideoPosts(posts);
      } catch (error) {
        console.error('Error loading video posts:', error);
      }
    };
    

    loadProfileData();
    loadVideoPosts();
  }, []);

  const paddedVideoData = padVideosWithPlaceholders(videoPosts);

  function handleOpenProfileFeed(post: PostProps) {
    const index = videoPosts.findIndex((video) => video.uri === post.uri);
    route.push({
      pathname: '../ProfileFeed',
      params: {
        videoData: JSON.stringify(videoPosts),
        initialIndex: index.toString(),
      },
    });
  }

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    scrollViewContent: {
      flexGrow: 1,
      paddingBottom: 20,
    },
    profileNavbar: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      paddingVertical: 10,
      paddingHorizontal: 20,
      marginBottom: 10,
    },
    profileTopText: {
      color: Colors[colorScheme ?? 'light'].text,
      fontSize: 24,
      paddingTop: 2,
    },
    profileHeader: {
      alignItems: 'center',
      width: '100%',
    },
    profileContent: {
      marginTop: 20,
    },
    tabButton: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 10,
      borderBottomWidth: 1,
      borderBottomColor: Colors[colorScheme ?? 'light'].underlineColor,
      marginBottom: 5,
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
          <View style={styles.profileNavbar}>
            <TouchableOpacity onPress={() => { }}>
              <Ionicons
                name="arrow-back"
                size={24}
                color={Colors[colorScheme ?? 'light'].text}
              />
            </TouchableOpacity>
            <ThemedText style={styles.profileTopText}>
              {userData?.displayName}
            </ThemedText>
            <TouchableOpacity onPress={() => { }}>
              <Ionicons
                name="ellipsis-horizontal"
                size={24}
                color={Colors[colorScheme ?? 'light'].text}
              />
            </TouchableOpacity>
          </View>
          <View style={styles.profileHeader}>
            {userData && <ProfilePicture userData={userData} />}
            {userData && <ProfileInfo userData={userData} />}
            <ActionButton title="Follow" onPress={() => { }} width={250} />
          </View>
          <View style={styles.profileContent}>
            <View style={styles.tabButton}>
              <Ionicons
                name="albums"
                size={24}
                color={Colors[colorScheme ?? 'light'].selectedIcon}
              />
              <ThemedText
                style={{
                  color: Colors[colorScheme ?? 'light'].selectedIcon,
                  marginLeft: 5,
                }}>
                Videos
              </ThemedText>
            </View>
            <View style={styles.videoGrid}>
              {paddedVideoData.map((item, index) => {
                const key = item.uri ? item.uri : `fallback-${index}`;

                if (item.isPlaceholder) {
                  return <PlaceholderVideoDisplay key={key} />;
                }
                return (
                  <VideoDisplay
                    key={key}
                    videoSource={item}
                    onVideoPress={handleOpenProfileFeed}
                  />
                );
              })}
            </View>
          </View>
        </ScrollView>
      </ContentWrapper>
    </SafeAreaView>
  );
}
