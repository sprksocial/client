import { Tabs } from 'expo-router';
import React, { useEffect, useState } from 'react';
import { Platform } from 'react-native';
import { HapticTab } from '@/components/HapticTab';
import { Ionicons } from '@expo/vector-icons';
import TabBarBackground from '@/components/ui/TabBarBackground';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import ProfileIcon from '@/components/global/ProfileIcon';
import { UserProps } from '@/types/Interfaces';
import { getProfile } from '@/api/profileServices';
import { did } from '@/constants/MockData';
import useAtProto from '@/hooks/useAtProto';
import { router } from 'expo-router';

export default function TabLayout() {
  const colorScheme = useColorScheme();

  const [userData, setUserData] = useState<UserProps | null>(null);
  const { isLoggedIn, session } = useAtProto();


useEffect(() => {
  if (isLoggedIn) {
    const loadProfileData = async () => {
      try {
        const profileData = await getProfile(session.did);
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
  } else {
    setUserData({
            id: '',
            did: '',
            displayName: 'Login or Register',
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
  }, []);

  return (
    <Tabs
    screenOptions={{
      tabBarActiveTintColor: Colors[colorScheme ?? 'light'].selectedIcon,
      tabBarInactiveTintColor: Colors[colorScheme ?? 'light'].notSelectedIcon,
      headerShown: false,
      tabBarShowLabel: false,
      tabBarButton: HapticTab,
      tabBarBackground: TabBarBackground,
      tabBarStyle: Platform.select({
        ios: {
          backgroundColor: Colors[colorScheme ?? 'light'].background,
          alignItems: 'center',
          justifyContent: 'space-between',
          display: 'flex',
          flexDirection: 'row',
          borderWidth: 0,
          safeAreaInsets: { bottom: 30 },
        },
        android: {
          backgroundColor: Colors[colorScheme ?? 'light'].background,
          alignItems: 'center',
          justifyContent: 'space-between',
          display: 'flex',
          flexDirection: 'row',
          borderWidth: 0,
          borderTopWidth: 0,
          elevation: 8,
        },
        default: {
          backgroundColor: Colors[colorScheme ?? 'light'].background,
          alignItems: 'center',
          justifyContent: 'space-between',
          display: 'flex',
          flexDirection: 'row',
          borderWidth: 0,
        },
      }),
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          tabBarItemStyle: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'row',
          },
          tabBarIcon: ({ color }) => <Ionicons name="albums"
          size={29}
          color={color} />,
        }}
      />
      <Tabs.Screen
        name="SearchScreen"
        options={{
          tabBarItemStyle: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'row',
          },
          tabBarIcon: ({ color }) => <Ionicons name="compass"
          size={30}
          color={color} />,
        }}
      />
        <Tabs.Screen
          name="CreateScreen"
          options={{
            tabBarItemStyle: {
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              flexDirection: 'row',
            },
            tabBarIcon: ({ color }) => <Ionicons name="add-circle"
            size={30}
            color={color} />,
          }}
        />
      <Tabs.Screen
        name="NotificationsScreen"
        options={{
          tabBarItemStyle: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'row',
          },
          tabBarIcon: ({ color }) => <Ionicons name="heart"
          size={30}
          color={color} />,
        }}
      />
      <Tabs.Screen
        name="ProfileScreen"
        options={{
          tabBarItemStyle: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'row',
          },
          tabBarIcon: ({ focused }) => userData ? <ProfileIcon uri={userData.avatar} isSelected={focused} size={28} /> : null,
        }}
        listeners={({ navigation }) => ({
          tabPress: () => {
            router.replace('/(tabs)/ProfileScreen');
          },
        })}
      />
    </Tabs>
  );
}
