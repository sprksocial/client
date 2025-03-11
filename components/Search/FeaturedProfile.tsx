import { FeaturedProfileProps } from "@/types/Interfaces";
import React from "react";
import { View, Text, Image, TouchableOpacity, StyleSheet, useColorScheme } from "react-native";
import { ThemedText } from "../ThemedText";
import { Ionicons } from "@expo/vector-icons";
import { Colors } from "@/constants/Colors";
import { navigateToProfile } from "@/app/(tabs)/ProfileScreen";

const formatNumber = (num?: number) => {
    if (!num) return '0';
    if (num >= 1_000_000_000) return (num / 1_000_000_000).toFixed(1) + 'B';
    if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
    if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
    return num.toString();
};

const FeaturedProfile: React.FC<FeaturedProfileProps> = ({
    user,
    onFollow,
    isFollowing,
}) => {
    const colorScheme = useColorScheme();

    const styles = StyleSheet.create({
        container: {
            flexDirection: "row",
            alignItems: "center",
            padding: 10,
            backgroundColor: Colors.light.background,
            borderRadius: 10,
            borderWidth: 1,
            borderColor: Colors[colorScheme ?? 'dark'].underlineColor,
            marginHorizontal: 5,
            marginBottom: 5,
        },
        profilePicture: {
            width: 40,
            height: 40,
            borderRadius: 30,
        },
        infoContainer: {
            flex: 1,
            marginLeft: 10,
        },
        name: {
            fontWeight: "bold",
        },
        username: {
            maxWidth: 120,
        },
        statsContainer: {
            flexDirection: "row",
            gap: 1,
        },
        stat: {
            fontSize: 12,
            color: "gray",
            marginRight: 4,
        },
        followButton: {
            backgroundColor: Colors[colorScheme ?? 'light'].tint,
            paddingVertical: 6,
            paddingHorizontal: 15,
            borderRadius: 6,
            marginRight: 4,
        },
        followButtonText: {
            color: Colors[colorScheme ?? 'light'].text,
            fontWeight: "bold",
        },
        nameContainer: {
            flexDirection: "row",
        },
    });

    return (
        <TouchableOpacity style={styles.container} onPress={() => navigateToProfile(user.did)}>
            <Image source={{ uri: user.avatar }} style={styles.profilePicture} />
            <View style={styles.infoContainer}>
                <View style={styles.nameContainer}>
                    <ThemedText type='name'
                        lightColor={Colors.light.text}
                        darkColor={Colors.light.text}
                        numberOfLines={1}
                        ellipsizeMode='tail'>{user.displayName}</ThemedText>
                    <ThemedText type="username">•</ThemedText>
                    <ThemedText type='username'
                        lightColor={Colors.dark.text}
                        darkColor={Colors.light.text}
                        style={styles.username}
                        numberOfLines={1}
                        ellipsizeMode='tail'>@{user.handle}</ThemedText>
                </View>
                <View style={styles.statsContainer}>
                    <ThemedText style={styles.stat}>{formatNumber(user.followersCount)} Followers</ThemedText>
                    <ThemedText style={styles.stat}>•</ThemedText>
                    <ThemedText style={styles.stat}>{formatNumber(user.followsCount)} Following</ThemedText>
                </View>
            </View>
            <TouchableOpacity 
                style={styles.followButton} 
                onPress={(e) => {
                    e.stopPropagation(); // Prevent triggering parent's onPress
                    onFollow();
                }}
            >
                <ThemedText style={styles.followButtonText}>{isFollowing ? <Ionicons name="person-remove" size={16} color="#fff" /> : <Ionicons name="person-add" size={16} color="#fff" />}</ThemedText>
            </TouchableOpacity>
        </TouchableOpacity>
    );
};

export default FeaturedProfile;