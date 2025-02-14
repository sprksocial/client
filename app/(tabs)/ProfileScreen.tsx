import React, { useEffect, useState } from 'react';
import { SafeAreaView, ScrollView, StyleSheet, TouchableOpacity, useColorScheme, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '@/components/ThemedText';
import ContentWrapper from '@/components/global/ContentWrapper';
import { Colors } from '@/constants/Colors';
import ProfilePicture from '@/components/Profile/ProfilePicture';
import ProfileInfo from '@/components/Profile/ProfileInfo';
import ActionButton from '@/components/global/ActionButton';
import VideoDisplay from '@/components/Profile/VideoDisplay';
import PlaceholderVideoDisplay from '@/components/Profile/PlaceholderVideoDisplay';
import { did, VIDEO_DATA } from '@/constants/MockData';
import { UserProps, VideoProps } from '@/types/Interfaces';
import { useRouter } from 'expo-router';
import { getProfile } from '@/api/profileServices';

function padVideosWithPlaceholders(videos: VideoProps[]): (VideoProps & { isPlaceholder?: boolean })[] {
  const remainder = videos.length % 3;
  const placeholdersNeeded = remainder === 0 ? 0 : 3 - remainder;
  const placeholders = Array(placeholdersNeeded).fill(null).map((_, i) => ({
    id: `placeholder-${i}`,
    isPlaceholder: true,
  }));
  return [...videos, ...placeholders];
}

export default function ProfileScreen() {
  const colorScheme = useColorScheme();
  const route = useRouter();

  const [userData, setUserData] = useState<UserProps | null>(null);

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
            likes: 0,
            views: 0,
            videos: profileData.videos || [],
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
        console.error("Error loading profile:", error);
      }
    };

  
    loadProfileData();
  }, []);

  const paddedVideoData = padVideosWithPlaceholders(VIDEO_DATA);

  function handleOpenProfileFeed(videoClicked: VideoProps) {
    const index = VIDEO_DATA.findIndex((video) => video.id === videoClicked.id);

    route.push({
      pathname: "../ProfileFeed",
      params: {
        videoData: JSON.stringify(VIDEO_DATA),
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
        <ScrollView contentContainerStyle={styles.scrollViewContent} showsVerticalScrollIndicator={false}>
          <View style={styles.profileNavbar}>
            <TouchableOpacity onPress={() => { }}>
              <Ionicons name="arrow-back" size={24} color={Colors[colorScheme ?? 'light'].text} />
            </TouchableOpacity>
            <ThemedText style={styles.profileTopText}>{userData?.displayName}</ThemedText>
            <TouchableOpacity onPress={() => { }}>
              <Ionicons name="ellipsis-horizontal" size={24} color={Colors[colorScheme ?? 'light'].text} />
            </TouchableOpacity>
          </View>
          <View style={styles.profileHeader}>
            {userData && (
              <ProfilePicture userData={userData ?? {}} />
            )}
            {userData && (
              <ProfileInfo userData={userData ?? {}} />
            )}
            <ActionButton title="Follow" onPress={() => { }} width={250} />
          </View>
          <View style={styles.profileContent}>
            <View style={styles.tabButton}>
              <Ionicons name="albums" size={24} color={Colors[colorScheme ?? 'light'].selectedIcon} />
              <ThemedText style={{ color: Colors[colorScheme ?? 'light'].selectedIcon, marginLeft: 5 }}>
                Videos
              </ThemedText>
            </View>
            <View style={styles.videoGrid}>
              {paddedVideoData.map((video) => {
                if (video.isPlaceholder) {
                  return <PlaceholderVideoDisplay key={video.id} />;
                }
                return (
                  <VideoDisplay
                    key={video.id}
                    videoSource={video}
                    onVideoPress={(video) => {
                      handleOpenProfileFeed(video);
                    }}
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