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

  // Ajuste aqui para os cenários que você quer simular:
  // - isLoggedIn = true/false
  // - isMine = true/false
  const isLoggedIn = true;    // Se está logado ou não
  const isMine = true;        // Se a conta do perfil atual é minha

  const [userData, setUserData] = useState<UserProps | null>(null);
  const [videoPosts, setVideoPosts] = useState<PostProps[]>([]);

  useEffect(() => {
    if (isLoggedIn) {
      // Carrega dados de um perfil "real"
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
          const posts = mediaPosts.map((item: PostProps) => item as PostProps);
          setVideoPosts(posts);
        } catch (error) {
          console.error('Error loading video posts:', error);
        }
      };
      loadProfileData();
      loadVideoPosts();
    } else {
      // Se não está logado, crie um "stub" de userData
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
  }, [isLoggedIn]);

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
              {userData?.displayName ?? ''}
            </ThemedText>

            <TouchableOpacity onPress={() => {}}>
              {/* No seu caso, pode ser "ellipsis-horizontal" ou vazio */}
              <Ionicons
                name="ellipsis-horizontal"
                size={24}
                color={Colors[colorScheme ?? 'light'].text}
              />
            </TouchableOpacity>
          </View>

          {/* Cabeçalho e foto do perfil */}
          <View style={styles.profileHeader}>
            {userData && <ProfilePicture userData={userData} />}
            {userData && <ProfileInfo userData={userData} />}

            {/* 
              4 CASOS (botões de ação):
              
              1) [logado && minha conta]: Editar / Compartilhar
              2) [logado && não é minha conta]: Seguir
              3) [não logado && não é minha conta]: Perfil + Botão "Seguir" (redireciona para login)
              4) [não logado && é minha conta]: Botões de "Login" / "Registrar"
            */}
            {
              !isLoggedIn && isMine && (
                // Não logado, mas é minha conta => mostrar Login / Register
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
                // Não logado e não é minha conta => mostrar "Seguir" (redireciona pra login)
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
                // Logado, mas não é minha conta => mostrar "Seguir"
                <ActionButton
                  type="primary"
                  title="Follow"
                  onPress={() => {
                    // Lógica real de seguir aqui
                    console.log("Seguiu este perfil");
                  }}
                  width={250}
                />
              )
            }
            {
              isLoggedIn && isMine && (
                // Logado e é minha conta => mostrar editar e compartilhar
                <View style={styles.profileActionButtons}>
                  <ActionButton
                    type="secondary"
                    title="Edit Profile"
                    onPress={() => {
                      console.log("Editar perfil");
                    }}
                    width={140}
                    icon="create"
                  />
                  <ActionButton
                    type="secondary"
                    title=""
                    onPress={() => {
                      console.log("Compartilhar perfil");
                    }}
                    width={70}
                    icon="share-social"
                  />
                </View>
              )
            }
          </View>

          {/* Tabs (Ex: Videos e Fotos) */}
          <View style={styles.profileContent}>
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

            {/* Grid de vídeos */}
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