import { Tabs } from 'expo-router';
import React from 'react';
import { Platform } from 'react-native';
import { HapticTab } from '@/components/HapticTab';
import { Ionicons } from '@expo/vector-icons';
import TabBarBackground from '@/components/ui/TabBarBackground';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';
import ProfileIcon from '@/components/global/ProfileIcon';

export default function TabLayout() {
  const colorScheme = useColorScheme();

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
          tabBarIcon: ({ focused }) => <ProfileIcon imageUrl="https://f.feridinha.com/rTd4R.png" isSelected={focused} size={28} />,
        }}
      />
    </Tabs>
  );
}
