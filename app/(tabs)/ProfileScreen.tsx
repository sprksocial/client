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
import { router, useRouter } from 'expo-router';
import { getProfile, getProfileMedia } from '@/api/profileServices';
import useAtProto from '@/hooks/useAtProto';

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

  // Get actual login status and user data from useAtProto hook
  const { isLoggedIn, session, agent, logout } = useAtProto();

  // This is the user's own profile if logged in
  const isMine = true;

  // User's DID comes from session when logged in, otherwise use mock DID
  const userDid = isLoggedIn && session ? session.did : did;

  const [userData, setUserData] = useState<UserProps | null>(null);
  const [videoPosts, setVideoPosts] = useState<PostProps[]>([]);

  const loadVideoPosts = async () => {
    try {
      // Use the actual user DID when logged in
      const mediaPosts = await getProfileMedia(userDid, 'video');
      const posts = mediaPosts.map((item: any) => item.post);
      setVideoPosts(posts);
    } catch (error) {
      console.error('Error loading video posts:', error);
    }
  };

  useEffect(() => {
    // When user is logged in OR (user is not logged in but viewing someone else's profile)
    if (isLoggedIn || (!isLoggedIn && !isMine)) {
      const loadProfileData = async () => {
        try {
          // Use the actual user DID when logged in
          const profileData = await getProfile(userDid);
          if (profileData) {
            setUserData({
              id: profileData.did,
              did: profileData.did,
              displayName: profileData.displayName || (session?.handle || ''),
              handle: profileData.handle || (session?.handle || ''),
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

          // If there's an error loading the profile but we're logged in,
          // at least display some basic info from the session
          if (isLoggedIn && session) {
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
      // When user is not logged in and viewing their own profile
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
  }, [isLoggedIn, isMine, session, userDid]);

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

  function goTo(route: string) {
    route = route.toLowerCase();
    if (route === 'register') {
      router.push('/(auth)/Register', { relativeToDirectory: true });
    } else {
      router.push('/(auth)/Login', { relativeToDirectory: true });
    }
  }

  // Handle logout
  const handleLogout = async () => {
    try {
      await logout();
      // You might want to navigate to a different screen or refresh the UI
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
      flexDirection: 'column',
      justifyContent: 'center',
      alignItems: 'center',
      gap: 10,
      width: '100%',
    },
    loginStatusContainer: {
      flexDirection: 'row',
      alignItems: 'center',
      marginTop: 10,
    },
    loginStatusIndicator: {
      width: 10,
      height: 10,
      borderRadius: 5,
      backgroundColor: Colors[colorScheme ?? 'light'].selectedIcon,
      marginRight: 5,
    },
    loginStatusText: {
      color: Colors[colorScheme ?? 'light'].text,
    },
  });

  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView
          contentContainerStyle={styles.scrollViewContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Navbar Superior */}
          <View style={styles.profileNavbar}>
            <TouchableOpacity onPress={() => {}}>
              <Ionicons
                name="chevron-back"
                size={24}
                color={Colors[colorScheme ?? 'light'].text}
              />
            </TouchableOpacity>

            <ThemedText style={styles.profileTopText}>
              {isLoggedIn ? 'My Profile' : userData?.displayName ?? ''}
            </ThemedText>

            <TouchableOpacity onPress={() => {}}>
              {isLoggedIn ? (
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

          {/* Cabeçalho e foto do perfil */}
          <View style={styles.profileHeader}>
            {userData && <ProfilePicture userData={userData} />}
            {userData && <ProfileInfo userData={userData} />}

            {/* Login status indicator */}
            {isLoggedIn && (
              <View style={styles.loginStatusContainer}>
                <View style={styles.loginStatusIndicator} />
                <ThemedText style={styles.loginStatusText}>Logged in as {session?.handle}</ThemedText>
              </View>
            )}

            {
              !isLoggedIn && isMine && (
                // Not logged in and viewing own profile => show Login / Register buttons
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
                // Not logged in and viewing someone else's profile => show "Follow" (redirects to login)
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
                // Logged in and viewing someone else's profile => show "Follow" with function
                <ActionButton
                  type="primary"
                  title="Follow"
                  onPress={() => {
                    // Follow logic here
                    console.log("followed " + userData?.did);
                  }}
                  width={250}
                />
              )
            }
            {
              isLoggedIn && isMine && (
                // Logged in and viewing own profile => Show logout button
                <View style={styles.profileActionButtonsVertical}>
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

          {/* Tabs (Ex: Videos e Fotos) */}
          <View style={styles.profileContent}>
          {/* Show tabs for everyone except when not logged in and viewing own profile */}
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
            {/* Grid de vídeos - Only show when logged in or viewing someone else's profile */}
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
    </SafeAreaView>
  );
}