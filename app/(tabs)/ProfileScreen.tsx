import React, { useEffect, useState, useRef, useCallback, useMemo } from 'react';
import {
  Platform,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  useColorScheme,
  View,
  Image,
  FlatList,
  RefreshControl,
  Alert,
  ActivityIndicator
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
import { router, useRouter, useLocalSearchParams } from 'expo-router';
import { getProfile, getProfileMedia } from '@/api/profileServices';
import useAtProto from '@/hooks/useAtProto';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';

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
  const params = useLocalSearchParams();
  
  const { isLoggedIn, session, agent, logout } = useAtProto();
  
  const profileDid = typeof params.did === 'string' && params.did ? 
    params.did : 
    (isLoggedIn && session ? session.did : did);
  
  const isMine = isLoggedIn && session && profileDid === session.did;

  const [userData, setUserData] = useState<UserProps | null>(null);
  const [videoPosts, setVideoPosts] = useState<PostProps[]>([]);
  
  const bottomSheetRef = useRef<BottomSheet>(null);
  const snapPoints = useMemo(() => ['25%'], []);

  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);

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
    profileTabs: {
      flexDirection: 'row',
      justifyContent: 'space-around',
      marginBottom: 10,
      width: '100%',
      borderBottomWidth: 1,
      borderBottomColor: Colors[colorScheme ?? 'light'].underlineColor,
    },
    tabButton: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 10,
    },
    videoGrid: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      justifyContent: 'center',
    },
    profileActionButtons: {
      flexDirection: 'row',
      justifyContent: 'center',
      gap: 10,
      width: '100%',
    },
    profileActionButtonsVertical: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 10,
      width: '100%',
    },
    bottomSheetContent: {
      padding: 20,
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    bottomSheetOption: {
      flexDirection: 'row',
      alignItems: 'center',
      paddingVertical: 15,
      borderBottomWidth: 1,
      borderBottomColor: Colors[colorScheme ?? 'light'].underlineColor,
    },
    bottomSheetOptionText: {
      marginLeft: 15,
      fontSize: 16,
      color: Colors[colorScheme ?? 'light'].text,
    },
    bottomSheetOptionTextDanger: {
      marginLeft: 15,
      fontSize: 16,
      color: '#FF3B30',
    },
    bottomSheetBackground: {
      backgroundColor: Colors[colorScheme ?? 'light'].background,
    },
    bottomSheetHandle: {
      backgroundColor: Colors[colorScheme ?? 'light'].underlineColor,
    },
  });

  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView
          contentContainerStyle={styles.scrollViewContent}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.profileNavbar}>
            <TouchableOpacity onPress={() => {
              if (params.did) {
                router.back();
              }
            }}>
              <Ionicons
                name="chevron-back"
                size={24}
                color={Colors[colorScheme ?? 'light'].text}
                style={{ opacity: params.did ? 1 : 0 }}
              />
            </TouchableOpacity>

            <ThemedText style={styles.profileTopText}>
              {isMine ? 'My Profile' : userData?.displayName ?? ''}
            </ThemedText>

            <TouchableOpacity onPress={openBottomSheet}>
              {isLoggedIn && isMine ? (
                <Ionicons
                  name="settings-outline"
                  size={24}
                  color={Colors[colorScheme ?? 'light'].text}
                />
              ) : (
                <Ionicons
                  name="ellipsis-horizontal"
                  size={24}
                  color={Colors[colorScheme ?? 'light'].text}
                />
              )}
            </TouchableOpacity>
          </View>

          <View style={!isLoggedIn && isMine ? styles.profileHeaderNull : styles.profileHeader}>
            {userData && <ProfilePicture userData={userData} />}
            {userData && <ProfileInfo userData={userData} />}

            {
              !isLoggedIn && isMine && (
                <View style={styles.profileActionButtonsVertical}>
                  <ActionButton
                    type="primary"
                    title="Registrar"
                    onPress={() => goTo('register')}
                    width="60%"
                  />
                  <ActionButton
                    type="outline"
                    title="Login"
                    onPress={() => goTo('login')}
                    width="60%"
                  />
                </View>
              )
            }
            {
              !isLoggedIn && !isMine && (
                <ActionButton
                  type="primary"
                  title="Follow"
                  onPress={() => goTo('login')}
                  width={250}
                />
              )
            }
            {
              isLoggedIn && !isMine && (
                <ActionButton
                  type="primary"
                  title="Follow"
                  onPress={() => {
                    console.log("followed " + userData?.did);
                  }}
                  width={250}
                />
              )
            }
            {
              isLoggedIn && isMine && (
                <View style={styles.profileActionButtons}>
                  <ActionButton
                    type="outline"
                    title="Logout"
                    onPress={handleLogout}
                    width="60%"
                  />
                </View>
              )
            }
          </View>

          <View style={styles.profileContent}>
          { (isLoggedIn || (!isLoggedIn && !isMine)) &&
            <View style={styles.profileTabs}>
              <View style={styles.tabButton}>
                <Ionicons
                  name="film"
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
              <View style={styles.tabButton}>
                <Ionicons
                  name="image"
                  size={24}
                  color={Colors[colorScheme ?? 'light'].notSelectedIcon}
                />
                <ThemedText
                  style={{
                    color: Colors[colorScheme ?? 'light'].notSelectedIcon,
                    marginLeft: 5,
                  }}>
                  Photos
                </ThemedText>
              </View>
            </View>
          }
            { (isLoggedIn || (!isLoggedIn && !isMine)) &&
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
            }
          </View>
        </ScrollView>
      </ContentWrapper>

      <BottomSheet
        ref={bottomSheetRef}
        index={-1}
        snapPoints={snapPoints}
        onChange={handleSheetChanges}
        enablePanDownToClose
        backgroundStyle={styles.bottomSheetBackground}
        handleIndicatorStyle={styles.bottomSheetHandle}
      >
        <BottomSheetView style={styles.bottomSheetContent}>
          <TouchableOpacity 
            style={styles.bottomSheetOption}
            onPress={handleProfileSettings}
          >
            <Ionicons
              name="person-circle-outline"
              size={24}
              color={Colors[colorScheme ?? 'light'].text}
            />
            <ThemedText style={styles.bottomSheetOptionText}>
              Profile Settings
            </ThemedText>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.bottomSheetOption}
            onPress={handleLogout}
          >
            <Ionicons
              name="log-out-outline"
              size={24}
              color="#FF3B30"
            />
            <ThemedText style={styles.bottomSheetOptionTextDanger}>
              Logout
            </ThemedText>
          </TouchableOpacity>
        </BottomSheetView>
      </BottomSheet>
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