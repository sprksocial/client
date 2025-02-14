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

export default function TabLayout() {
  const colorScheme = useColorScheme();

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
          height: '10%',
          alignItems: 'center',
          justifyContent: 'space-between',
          display: 'flex',
          flexDirection: 'row',
          borderWidth: 0,
        },
        default: {
          backgroundColor: Colors[colorScheme ?? 'light'].background,
          height: 60,
          alignItems: 'center',
          justifyContent: 'space-between',
          display: 'flex',
          flexDirection: 'row',
          borderWidth: 0,
        },
      }),
      }}>
      <Tabs.Screen
        name="index"
        options={{
          tabBarItemStyle: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'row',
          },
          tabBarIcon: ({ color }) => <Ionicons name="film"
          size={30}
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
          tabBarIcon: ({ focused }) => userData ? <ProfileIcon userData={userData} isSelected={focused} size={28} /> : null,
        }}
      />
    </Tabs>
  );
}
