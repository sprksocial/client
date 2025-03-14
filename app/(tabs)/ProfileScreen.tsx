import React, { useEffect, useState, useRef, useCallback } from 'react';
import {
  Platform,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  useColorScheme,
  View,
  Share,
} from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import ContentWrapper from '@/components/global/ContentWrapper';
import { Colors } from '@/constants/Colors';
import ProfileInfo from '@/components/Profile/ProfileInfo';
import { did } from '@/constants/MockData';
import { UserProps, PostProps } from '@/types/Interfaces';
import { router, useRouter, useLocalSearchParams } from 'expo-router';
import { getProfile, getProfileMedia } from '@/api/profileServices';
import useAtProto from '@/hooks/useAtProto';
import BottomSheet from '@gorhom/bottom-sheet';

// Import new modular components
import ProfileHeader from '@/components/Profile/ProfileHeader';
import ProfileActionButtons from '@/components/Profile/ProfileActionButtons';
import ProfileTabs from '@/components/Profile/ProfileTabs';
import ProfileVideoGrid, { padVideosWithPlaceholders } from '@/components/Profile/ProfileVideoGrid';
import ProfileOptionsBottomSheet from '@/components/Profile/ProfileOptionsBottomSheet';

export default function ProfileScreen() {
  const colorScheme = useColorScheme();
  const route = useRouter();
  const params = useLocalSearchParams();
  
  const { isLoggedIn, session, agent, logout } = useAtProto();
  
  const profileDid = typeof params.did === 'string' && params.did ? 
    params.did : 
    (isLoggedIn && session ? session.did : did);
  
  const isMine = isLoggedIn && session && profileDid === session.did;

  const [userData, setUserData] = useState<UserProps | null>(null);
  const [videoPosts, setVideoPosts] = useState<PostProps[]>([]);
  const [activeTab, setActiveTab] = useState<'videos' | 'photos'>('videos');
  
  const bottomSheetRef = useRef<BottomSheet>(null);

  const openBottomSheet = useCallback(() => {
    bottomSheetRef.current?.expand();
  }, []);

  const closeBottomSheet = useCallback(() => {
    bottomSheetRef.current?.close();
  }, []);

  const loadVideoPosts = async () => {
    try {
      const mediaPosts = await getProfileMedia(profileDid, 'video');
      const posts = mediaPosts.map((item: any) => item.post);
      setVideoPosts(posts);
    } catch (error) {
      console.error('Error loading video posts:', error);
    }
  };

  useEffect(() => {
    if (isLoggedIn || (!isLoggedIn && !isMine)) {
      const loadProfileData = async () => {
        try {
          const profileData = await getProfile(profileDid);
          if (profileData) {
            setUserData({
              id: profileData.did,
              did: profileData.did,
              displayName: profileData.displayName || (isMine && session?.handle ? session.handle : ''),
              handle: profileData.handle || (isMine && session?.handle ? session.handle : ''),
              description: profileData.description || '',
              avatar: profileData.avatar || '',
              banner: profileData.banner || '',
              followersCount: profileData.followersCount || 0,
              followsCount: profileData.followsCount || 0,
              postsCount: profileData.postsCount || 0,
              associated: profileData.associated,
              joinedViaStarterPack: profileData.joinedViaStarterPack,
              indexedAt: profileData.indexedAt || '',
              createdAt: profileData.createdAt || '',
              viewer: profileData.viewer,
              labels: profileData.labels || [],
              pinnedPost: profileData.pinnedPost,
            });
          }
        } catch (error) {
          console.error('Error loading profile:', error);

          if (isLoggedIn && session && isMine) {
            setUserData({
              id: session.did,
              did: session.did,
              displayName: session.handle || 'My Profile',
              handle: session.handle || '',
              description: '',
              avatar: '',
              banner: '',
              followersCount: 0,
              followsCount: 0,
              postsCount: 0,
              indexedAt: '',
              createdAt: '',
              labels: [],
            });
          }
        }
      };

      loadProfileData();
      loadVideoPosts();
    } else if (!isLoggedIn && isMine) {
      setUserData({
        id: '',
        did: '',
        displayName: 'Login ou Registrar',
        handle: 'null',
        description: '',
        avatar: 'https://static.sprk.so/branding/default-profile.png?d',
        banner: '',
        followersCount: 0,
        followsCount: 0,
        postsCount: 0,
        indexedAt: '',
        createdAt: '',
        labels: [],
      });
    }
  }, [isLoggedIn, isMine, session, profileDid]);

  const paddedVideoData = padVideosWithPlaceholders(videoPosts);

  function handleOpenProfileFeed(post: PostProps) {
    const index = videoPosts.findIndex((video) => video.uri === post.uri);
    route.push({
      pathname: '../ProfileFeed',
      params: {
        videoData: JSON.stringify(videoPosts),
        initialIndex: index.toString(),
        animation: Platform.OS === 'android' ? 'fade' : 'none'
      },
    });
  }

  function goTo(route: string) {
    route = route.toLowerCase();
    if (route === 'register') {
      router.push('/(auth)/Register', { relativeToDirectory: true });
    } else {
      router.push('/(auth)/Login', { relativeToDirectory: true });
    }
  }

  const handleProfileSettings = () => {
    closeBottomSheet();
    console.log('Navigate to profile settings');
  };

  const handleLogout = async () => {
    try {
      closeBottomSheet();
      await logout();
      console.log('User logged out');
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  const handleTabChange = (tab: 'videos' | 'photos') => {
    setActiveTab(tab);
  };

  const handleFollow = () => {
    console.log("followed " + userData?.did);
  };

  // New handlers for profile actions
  const handleEdit = () => {
    console.log("Edit profile functionality would be implemented here");
    // TODO: Implement profile editing screen
  };

  const handleShareProfile = async () => {
    try {
      if (userData) {
        const profileUrl = `https://sprk.so/${userData.handle}`;
        await Share.share({
          message: `Check out ${userData.displayName}'s profile on Spark: ${profileUrl}`,
          url: profileUrl,
        });
        console.log("Shared profile");
      }
    } catch (error) {
      console.error('Error sharing profile:', error);
    }
  };

  const handleFriends = () => {
    console.log("Friends functionality would be implemented here");
    // TODO: Implement friends screen
  };

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    scrollViewContent: {
      flexGrow: 1,
      paddingBottom: 20,
    },
    profileHeader: {
      alignItems: 'center',
      width: '100%',
    },
    profileHeaderNull: {
      alignItems: 'center',
      width: '100%',
      justifyContent: 'center',
      height: '70%',
    },
    profileContent: { 
      marginTop: 20,
      height: '100%',
    },
  });

  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView
          contentContainerStyle={styles.scrollViewContent}
          showsVerticalScrollIndicator={false}
        >
          <ProfileHeader 
            title={isMine ? 'My Profile' : userData?.displayName ?? ''}
            showBackButton={!!params.did}
            onBackPress={() => {
              if (params.did) {
                router.back();
              }
            }}
            onSettingsPress={openBottomSheet}
            isSettingsVisible={isLoggedIn && isMine}
          />

          <View style={!isLoggedIn && isMine ? styles.profileHeaderNull : styles.profileHeader}>
            {userData && <ProfileInfo userData={userData} />}
            
            <ProfileActionButtons
              isLoggedIn={isLoggedIn}
              isMine={isMine}
              onRegister={() => goTo('register')}
              onLogin={() => goTo('login')}
              onFollow={handleFollow}
              onLogout={handleLogout}
              onEdit={handleEdit}
              onShareProfile={handleShareProfile}
              onFriends={handleFriends}
            />
          </View>

          <View style={styles.profileContent}>
            {(isLoggedIn || (!isLoggedIn && !isMine)) && (
              <>
                <ProfileTabs 
                  activeTab={activeTab}
                  onTabChange={handleTabChange}
                />
                
                <ProfileVideoGrid 
                  videos={paddedVideoData}
                  onVideoPress={handleOpenProfileFeed}
                />
              </>
            )}
          </View>
        </ScrollView>
      </ContentWrapper>

      <ProfileOptionsBottomSheet 
        bottomSheetRef={bottomSheetRef} 
        onProfileSettings={handleProfileSettings}
        onLogout={handleLogout}
      />
    </SafeAreaView>
  );
}

// Utility function to navigate to a profile
export function navigateToProfile(did: string) {
  // If navigating to a profile, always include the DID parameter
  // This allows the correct handling when coming from different contexts
  router.push({
    pathname: "/(tabs)/ProfileScreen",
    params: { did }
  });
}